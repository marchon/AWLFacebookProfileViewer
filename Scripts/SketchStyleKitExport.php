<?php namespace WaveLabs;

$logger = Logger::getLogger("main");
$logger->info("Starting...");

$options = getopt('i:o:h');
if (array_key_exists('h', $options)) {
    echo usageString();
} else if (array_key_exists('i', $options) && array_key_exists('o', $options)) {
    $inputPath = $options['i'];
    $outputPath = $options['o'];
    if (!(file_exists($inputPath) && is_file($inputPath))) {
        $logger->error(sprintf("Invalid input file: \"%s\".", $inputPath));
        exit(1);
    }
    $exporter = new SketchStyleKitExporter(realpath($inputPath), $outputPath);
    $exporter->performExport();

} else {
    echo usageString();
}

$logger->info("Export completed.");
exit(0);

function usageString() {
    $usage = "Usage: php " . basename(__FILE__) . ' -i <document> -o <path>';

    return $usage . "\n";
}


class Logger {
    private $name = '';
    function info($msg) {echo "[I] [$this->name] $msg\n";}
    function error($msg) {echo "[E] [$this->name] $msg\n";}
    private function __construct($name) {
        $this->name = $name;
    }
    public static function getLogger($name) {
        return new Logger($name);
    }
}

class SketchStyleKitExporter  {
    private $sketchFile = '';
    private $outputFile = '';
    /**
     * @var Logger
     */
    private $log;
    private $styleKitBuilder;

    function __construct($sketchFile, $outputFile) {
        $this->sketchFile = $sketchFile;
        $this->outputFile = $outputFile;
        $this->log = Logger::getLogger("exporter");
        $this->styleKitBuilder = new StyleKitBuilder(pathinfo($outputFile, PATHINFO_FILENAME));
    }

    function performExport() {
        $JSON = $this->dumpStructure();
        $layerStyles = $JSON['layerStyles'];
        $layerTextStyles = $JSON['layerTextStyles'];
        $layerStyles = $this->preprocessLayerStyles($layerStyles);
        $layerTextStyles = $this->preprocessLayerStyles($layerTextStyles);

        $this->log->info(sprintf("Will process %d shared styles", count($layerStyles)));
        foreach ($layerStyles as $layerStyle) {
            $this->styleKitBuilder->addLayerStyle($layerStyle['name'], $layerStyle['value']);
        }

        $this->log->info(sprintf("Will process %d shared text styles", count($layerTextStyles)));
        foreach ($layerTextStyles as $layerStyle) {
            $this->styleKitBuilder->addLayerTextStyle($layerStyle['name'], $layerStyle['value']);
        }

        $this->styleKitBuilder->saveToFile($this->outputFile);
    }

    private function preprocessLayerStyles($JSON) {
        $layerStyles = $JSON['objects']['<items>'];
        // Filtering out unused layers
        $layerStyles = array_filter($layerStyles, function ($var) {
            $instances = $var['instances']['<items>'];
            $isUsed = count($instances) > 0;
            if (!$isUsed) {
                $this->log->info(sprintf("Skipping unused layer: \"%s\"", $var['name']));
            }
            return $isUsed;
        });

        // Removing metadata from array
        $layerStyles = array_map(function ($var) {
            unset($var['instances'], $var['<class>'], $var['objectID']);
            return $var;
        }, $layerStyles);

        return $layerStyles;
    }

    private function dumpStructure() {
        $JSONString = $this->executeCommand("sketchtool dump \"$this->sketchFile\"");
        $JSON = json_decode($JSONString, true);
        return $JSON;
    }

    private function executeCommand($cmd) {
        $outputLines = '';
        $returnCode = 0;
        exec($cmd, $outputLines, $returnCode);
        if ($returnCode != 0) {
            $this->log->error("Unable to execute command '$cmd'");
            exit(1);
        }
        return implode('', $outputLines);
    }
}

class StyleKitBuilder {

    private static $template = <<<HEADER
//
// File: {file_name}
//
// NOTE:
// File automatically generated by "{tool_name}" tool.
// Any modification will lost on next export!

import UIKit

private extension UIColor {
  class func fromRGB(hex: Int) -> UIColor {
    let R = CGFloat((hex & 0xFF0000) >> 16) / 255.0
    let G = CGFloat((hex & 0xFF00) >> 8) / 255.0
    let B = CGFloat(hex & 0xFF) / 255.0
    return UIColor(red: R, green: G, blue: B, alpha: 1.0)
  }
}
HEADER;

    /**
     * @var StyleKitClass
     */
    private $styleKitClass;

    /**
     * @var StyleKitLayerStyle[]
     */
    private $layerStyles = array();

    /**
     * @var StyleKitLayerTextStyle[]
     */
    private $layerTextStyles = array();

    function __construct($styleKitName) {
        $this->styleKitClass = new StyleKitClass($styleKitName);
    }

    public function addLayerStyle($name, $JSONValue) {
        $this->layerStyles[$name] = new StyleKitLayerStyle($name, $JSONValue);
    }

    public function addLayerTextStyle($name, $JSONValue) {
        $this->layerTextStyles[$name] = new StyleKitLayerTextStyle($name, $JSONValue);
    }

    public function saveToFile($outputFilePath) {
        ksort($this->layerStyles);
        ksort($this->layerTextStyles);

        $layerStylesContents = '';
        foreach($this->layerStyles as $name => $layerStyle) {
            $layerStylesContents .= "\n" . $layerStyle->build() . "\n";
        }
        foreach($this->layerTextStyles as $name => $layerStyle) {
            $layerStylesContents .= "\n" . $layerStyle->build() . "\n";
        }

        $layerStylesContents = StyleKitBuilder::indentCode($layerStylesContents);
        $contents = $this->styleKitClass->build();
        $header = str_replace('{file_name}', basename($outputFilePath), StyleKitBuilder::$template);
        $header = str_replace('{tool_name}', basename(__FILE__), $header);
        $contents = str_replace('{file_header}', $header, $contents);
        $contents = str_replace('{class_members}', $layerStylesContents, $contents);
        file_put_contents($outputFilePath, $contents);
    }

    public static function indentCode($input) {
        $lines = explode("\n", $input);
        $lines = array_map(function ($var) {
            if(strlen($var) > 0) {
                $var = "    ".$var;
            }
            return $var;
        }, $lines);
        $output = implode("\n", $lines);
        return $output;
    }
}

class StyleKitClass {

    private static $template = <<<TEMPLATE
{file_header}

public class {class_name} {
    {class_members}
}

TEMPLATE;

    private $name = '';

    function __construct($className) {
        $this->name = $className;
    }

    public function build() {
        return str_replace('{class_name}', $this->name, StyleKitClass::$template);
    }
}

class StyleKitLayerStyle {

    protected static $templateForClassDefinition = <<<T

public class {class_name} {
{class_members}
}
T;

    protected $name = '';
    /**
     * @var StyleKitLayerFill[]
     */
    protected $fills = array();
    /**
     * @var StyleKitLayerBorder[]
     */
    protected $borders = array();

    /**
     * @return string
     */
    public function getFunctionName() {
        // Replace unsafe characters
        $safeName = str_ireplace(' ', '', trim($this->name));
        $safeName = str_ireplace(':', '', $safeName);
        $safeName = strtolower(substr($safeName, 0, 1)).substr($safeName, 1, strlen($safeName) - 1);
        return $safeName;
    }

    function __construct($layerName, $JSONValue) {
        $this->name = $layerName;
        $fills = $JSONValue['fills']['<items>'];
        foreach ($fills as $fill) {
            $isEnabled = $fill['isEnabled'] == 1;
            if ($isEnabled) {
                $this->fills[] = new StyleKitLayerFill($fill);
            }
        }
        $borders = $JSONValue['borders']['<items>'];
        foreach ($borders as $border) {
            $isEnabled = $border['isEnabled'] == 1;
            if ($isEnabled) {
                $this->borders[] = new StyleKitLayerBorder($border);
            }
        }
    }

    public function build() {
        $contents = "// LayerStyle: \"$this->name\"";
        $contents .= str_replace('{class_name}', $this->getFunctionName(), StyleKitLayerStyle::$templateForClassDefinition);
        $classMembers = '';
        foreach($this->fills as $fill) {
            $classMembers .= $fill->build();
        }
        if(count($this->borders) > 0) {
            $classMembers .= "\n";
        }
        foreach($this->borders as $border) {
            $classMembers .= $border->build();
        }
        $contents = str_replace('{class_members}', StyleKitBuilder::indentCode($classMembers), $contents);
        return $contents;
    }
}

class StyleKitLayerTextStyle extends StyleKitLayerStyle {

    /**
     * @var StyleKitColor
     */
    protected $fontColor;

    /**
     * @var StyleKitFont
     */
    protected $font;

    function __construct($layerName, $JSONValue) {
        parent::__construct($layerName, $JSONValue);
        $textStyle = $JSONValue['textStyle'];
        // Ignoring font color if there are fills exists
        if (count($this->fills) == 0) {
            $this->fontColor = new StyleKitColor($textStyle['NSColor']['color'], 'textColor');
            $this->fontColor->RGBAMode = StyleKitColorRGBAMode::k0_1Value;
        }
        $this->font = new StyleKitFont($textStyle['NSFont']['attributes']);
    }

    public function build() {
        $contents = "// LayerTextStyle: \"$this->name\"";
        $contents .= str_replace('{class_name}', $this->getFunctionName(), StyleKitLayerStyle::$templateForClassDefinition);
        $classMembers = $this->font->build() . "\n";
        if (count($this->fills) == 0) {
            $classMembers .= $this->fontColor->build();
        } else {
            foreach($this->fills as $fill) {
                $classMembers .= $fill->build();
            }
        }
        if(count($this->borders) > 0) {
            $classMembers .= "\n";
        }
        foreach($this->borders as $border) {
            $classMembers .= $border->build();
        }
        $contents = str_replace('{class_members}', StyleKitBuilder::indentCode($classMembers), $contents);
        return $contents;
    }
}

abstract class StyleKitLayerFillType {
    const FlatColor = 0;
    const LinearGradient = 1; // TODO: Rest need to be checked
    const RadiantGradient = 2;
    const AngularGradient = 3;
    const PatternFill = 4;
    const NoiseFill = 5;
}

class StyleKitLayerFill {

    private $log;
    private $fillType = StyleKitLayerFillType::FlatColor;
    private $color = '';
    function __construct($JSONValue) {
        $this->log = Logger::getLogger("LayerFill");
        $this->fillType = $JSONValue['fillType'];
        switch ($this->fillType) {
            case StyleKitLayerFillType::FlatColor:
                $this->color = new StyleKitColor($JSONValue['color']['value'], 'fillColor');
                break;
            default:
                $this->log->error("Fill type %d is not implemented yet", $this->fillType);
                break;
        }
    }

    public function build() {
        $color = '';
        switch ($this->fillType) {
            case StyleKitLayerFillType::FlatColor:
                $color = $this->color->build();
                break;
            default:
                $this->log->error("Fill type %d is not implemented yet", $this->fillType);
                break;
        }
        return $color;
    }
}

class StyleKitLayerBorder {

    private $log;
    private $fillType = StyleKitLayerFillType::FlatColor;
    private $color = '';
    function __construct($JSONValue) {
        $this->log = Logger::getLogger("LayerBorder");
        $this->fillType = $JSONValue['fillType'];
        switch ($this->fillType) {
            case StyleKitLayerFillType::FlatColor:
                $this->color = new StyleKitColor($JSONValue['color']['value'], 'borderColor');
                break;
            default:
                $this->log->error("Fill type %d is not implemented yet", $this->fillType);
                break;
        }
    }

    public function build() {
        $color = '';
        switch ($this->fillType) {
            case StyleKitLayerFillType::FlatColor:
                $color = $this->color->build();
                break;
            default:
                $this->log->error("Fill type %d is not implemented yet", $this->fillType);
                break;
        }
        return $color;
    }
}

abstract class StyleKitColorRGBAMode {
    const k0_256Value = 0;
    const k0_1Value = 1;
}

class StyleKitColor {

    protected static $templateHexColor = <<<T
public var {member_name}: UIColor {
    return UIColor.fromRGB(0x{hex_code})
}
T;

    protected static $templateRGBAColor = <<<T
public var {member_name}: UIColor {
    return UIColor(red: {red} / 255.0, green: {green} / 255.0, blue: {blue} / 255.0, alpha: {alpha})
}
T;

    protected static $templateRGBANSColor = <<<T
public var {member_name}: UIColor {
    return UIColor(red: {red}, green: {green}, blue: {blue}, alpha: {alpha})
}
T;

    private $log;
    private $color = '';
    private $memberName = '';
    public $RGBAMode = StyleKitColorRGBAMode::k0_256Value;
    function __construct($JSONValue, $memberName) {
        $this->log = Logger::getLogger("Color");
        $this->color = $JSONValue;
        $this->memberName = $memberName;
    }

    public function build() {
        $color = '';
        if (substr_compare($this->color, "#", 0, 1, true) == 0) {
            $color = str_replace('{hex_code}', substr($this->color, 1, 6), StyleKitColor::$templateHexColor);
        } else if (substr_compare($this->color, "rgba", 0, 4, true) == 0) {
            $template = $this->RGBAMode == StyleKitColorRGBAMode::k0_256Value ? StyleKitColor::$templateRGBAColor : StyleKitColor::$templateRGBANSColor;
            $rgba = str_replace("rgba", "", $this->color);
            $rgba = substr($rgba, 1, -1);
            $rgba = explode(",", $rgba);
            $color = str_replace('{red}', $rgba[0], $template);
            $color = str_replace('{green}', $rgba[1], $color);
            $color = str_replace('{blue}', $rgba[2], $color);
            $color = str_replace('{alpha}', $rgba[3], $color);
        } else {
            $this->log->error("Unsupported color string: %s", $this->color);
        }
        $color = str_replace('{member_name}', $this->memberName, $color);
        return $color;
    }
}

class StyleKitFont {

    protected static $templateFont = <<<T
public var font: UIFont {
    return UIFont(name: "{font_name}", size: {font_size})!
}
T;

    private $name = '';
    private $size = '';

    function __construct($JSONValue) {
        $this->name = $JSONValue['NSFontNameAttribute'];
        $this->size = $JSONValue['NSFontSizeAttribute'];
    }

    public function build() {
        $font = str_replace('{font_name}', $this->name, StyleKitFont::$templateFont);
        $font = str_replace('{font_size}', $this->size, $font);
        return $font;
    }
}

?>
