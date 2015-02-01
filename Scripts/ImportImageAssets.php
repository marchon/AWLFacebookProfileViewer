<?php

$logger = new Logger();
$logger->info("Starting...");

$options = getopt('i:o:h');
if (array_key_exists('h', $options)) {
    echo usageString();
} else if (array_key_exists('i', $options) && array_key_exists('o', $options)) {
    $inputPath = $options['i'];
    $outputPath = $options['o'];
    if (!(file_exists($inputPath) && is_dir($inputPath))) {
        $logger->error(sprintf("Invalid input directory: \"%s\".", $inputPath));
        exit(1);
    }
    if (!(file_exists($outputPath) && is_dir($outputPath))) {
        $logger->error(sprintf("Invalid output directory: \"%s\".", $outputPath));
        exit(1);
    }
    performExport($inputPath, $outputPath);
} else {
    echo usageString();
}

$logger->info("Export completed.");
exit(0);


function performExport($inputPath, $outputPath) {
    $logger = new Logger();
    $directoryIterator = new DirectoryIterator($inputPath);
    // Expected format: "Asset Name@Zx.ext"
    $regexIterator = new RegexIterator($directoryIterator, '/^(.+)@([\d]x)\.(png|jpg|tiff)$/i', RegexIterator::GET_MATCH);
    foreach($regexIterator as $match)
    {
        $image = new Image($match[1], $match[2], $match[3]);

        $imageSet = new ImageSet($image->getName());
        $imageSet->addImage($image);

        $outputDirectoryPath = $outputPath.'/'.$image->getName().'.imageset';

        $components = array();
        // Searching for category name
        // Expected images in naming format: "Category: Asset Name@Zx.ext"
        $status = preg_match('/^(.+)\:\s+(.+)$/i', $image->getName(), $components);
        if ($status == 1)
        {
            $folderName = $components[1];
            $assetName = $components[0].'.imageset';

            $outputDirectoryPath = $outputPath.'/'.$folderName.'/'.$assetName;
        }

        if (!file_exists($outputDirectoryPath)) {
            mkdir($outputDirectoryPath, 0777, true);
        }

        $configFile = $outputDirectoryPath.'/Contents.json';
        if (!file_exists($configFile)) {
            $logger->info("Writing default \"Contents.json\" file.");
            file_put_contents($configFile, $imageSet->toJson());
        }

        $sourceFile = $inputPath.'/'.$image->getFullName();
        $destinationFile = $outputDirectoryPath.'/'.$image->getFullName();

        $logger->info(sprintf("Copying file \"%s\"...", $image->getName()));
        if (!copy ($sourceFile, $destinationFile)) {
            $logger->error(sprintf("Unable to copy from \"%s\" to \"%s\".", $sourceFile, $destinationFile));
            exit (1);
        }

    }
}

function usageString() {
    $usage = "Usage: ".basename(__FILE__).' -i /path/to/input/directory -o /path/to/output/directory';
    return $usage;
}

class Image {

    private $name = '';
    private $scale = '';
    private $extension = '';

    function __construct($name, $scale, $extension) {
        $this->name = $name;
        $this->scale = $scale;
        $this->extension = $extension;
    }

    function getFullName() {
        return $this->name.'@'.$this->scale.'.'.$this->extension;
    }

    function toDictionary() {
        $dictionary = array();
        $dictionary['idiom'] = "universal";
        $dictionary['scale'] = $this->scale;
        if ($this->name != '' && $this->extension != '') {
            $dictionary['filename'] = $this->getFullName();
        }
        return $dictionary;
    }

    public function getName() {
        return $this->name;
    }

    public function getScale() {
        return $this->scale;
    }
}


class ImageSet {

    private $name = '';
    private $images = array();

    function __construct($name) {
        $this->name = $name;
        $this->addImage(new Image('', '1x', ''));
        $this->addImage(new Image('', '2x', ''));
        $this->addImage(new Image('', '3x', ''));
    }

    function addImage(Image $image) {
        $this->images[$image->getScale()] = $image;
    }

    function toJson() {
        $info = array();
        $info['version'] = 1;
        $info['author'] = 'xcode';

        $images = array();
        foreach ($this->images as &$value) {
            $image = (object)$value;
            $images[] = $image->toDictionary();
        }
        $dictionary = array(
            'images' => $images,
            'info' => $info);
        return json_encode($dictionary, JSON_PRETTY_PRINT);
    }
}

// Stub for log4php
class Logger {
    function info($msg) {echo "[I] $msg\n";}
    function error($msg) {echo "[E] $msg\n";}
}

?>