<?php

$logger = Logger::getLogger("main");
$logger->info("Starting...");

$options = getopt('i:o:h', array('page::'));
if (array_key_exists('h', $options)) {
    echo usageString();
} else if (array_key_exists('i', $options) && array_key_exists('o', $options)) {
    $inputPath = $options['i'];
    $outputPath = $options['o'];
    if (!(file_exists($inputPath) && is_file($inputPath))) {
        $logger->error(sprintf("Invalid input file: \"%s\".", $inputPath));
        exit(1);
    }
    if (!(file_exists($outputPath) && is_dir($outputPath))) {
        $logger->error(sprintf("Invalid output directory: \"%s\".", $outputPath));
        exit(1);
    }
    $page = '';
    if (array_key_exists('page', $options)) {
        $page = $options['page'];
    }

    $exporter = new SketchExporter(realpath($inputPath), realpath($outputPath), $page);
    $exporter->performExport();

} else {
    echo usageString();
}

$logger->info("Export completed.");
exit(0);

function usageString() {
    $usage = "Usage: php " . basename(__FILE__) . ' -i <document> -o <path> [ --page=<string> ]';

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

class SketchExporter {

    private $sketchFile = '';
    private $outputPath = '';
    private $pageName = '';
    /**
     * @var Logger
     */
    private $log;

    private $tempFolderPrefix = 'sketch-export-';

    function __construct($sketchFile, $outputPath, $pageName) {
        $this->sketchFile = $sketchFile;
        $this->outputPath = $outputPath;
        $this->pageName = $pageName;
        $this->log = Logger::getLogger("SketchExporter");
    }

    function performExport() {
        $JSON = $this->getSketchDocumentSlices($this->sketchFile);
        $slices = $this->getSlicesToExport($JSON, $this->pageName);
        $exportDir = $this->exportSlices($slices, $this->sketchFile);
        $imageSets = $this->collectImageSets($exportDir);
        if (strtolower($this->pageName) == 'appicons') { // Special case => AppIcon.appiconset
            $this->doExportAppIconSet($exportDir, $imageSets);
        } else {
            $this->doExport($exportDir, $this->outputPath, $imageSets);
        }
        $this->cleanupTempFolder();
    }

    private function exportSlices($slices, $inputPath) {
        $argItems = implode(', ', $slices);
        $tempDir = $this->makeTempFolder($this->tempFolderPrefix);

        $cmd = "sketchtool export slices \"$inputPath\" --output=\"$tempDir\" --items=\"$argItems\" --formats=\"png\" --scales=\"0.5, 1.0, 1.5\" --overwriting=YES --save-for-web=YES";
        $this->executeCommand($cmd);

        $this->fixSlicesNames($tempDir);
        return $tempDir;
    }

    private function makeTempFolder($prefix) {
        $tempFile = tempnam(sys_get_temp_dir(), $prefix);
        if (file_exists($tempFile)) {
            unlink($tempFile);
        }
        mkdir($tempFile);
        return $tempFile;
    }

    private function cleanupTempFolder() {
        $directoryIterator = new DirectoryIterator(sys_get_temp_dir());
        $regexIterator = new RegexIterator($directoryIterator, '/^'.$this->tempFolderPrefix.'.+/i', RegexIterator::MATCH);
        foreach ($regexIterator as $match) {
            $dirName = $match->getPathname();
            system("rm -rf " . escapeshellarg($dirName));
        }
    }

    private function fixSlicesNames($tempfile) {

        $outDir = "$tempfile/renamed";
        mkdir($outDir, 0777, true);

        $flags = FilesystemIterator::KEY_AS_PATHNAME | FilesystemIterator::CURRENT_AS_FILEINFO | FilesystemIterator::SKIP_DOTS | FilesystemIterator::UNIX_PATHS;
        $directoryIterator = new FilesystemIterator($tempfile, $flags);
        foreach ($directoryIterator as $path => $fileInfo) {

            if ($fileInfo->isDir()) {
                continue;
            }

            $extension = $fileInfo->getExtension();
            $baseName = $fileInfo->getBasename('.' . $extension);
            $nameComponents = explode('@', $baseName);
            $newScaleFactor = '';
            if (count($nameComponents) == 2) {
                if ($nameComponents[1] == '0.5x') {
                    // This is actually @1x image
                    $newScaleFactor = '@1x';
                } else if ($nameComponents[1] == '1x') {
                    // This is actually @3x image
                    $newScaleFactor = '@3x';
                }
            } else {
                // This is actually 2x image.
                $newScaleFactor = '@2x';
            }
            $destination = $outDir . '/' . $nameComponents[0] . $newScaleFactor . '.' . $extension;
            rename($path, $destination);
        }

        $directoryIterator = new FilesystemIterator($outDir, $flags);
        foreach ($directoryIterator as $path => $fileInfo) {
            if ($fileInfo->isDir()) {
                continue;
            }
            $fileName = $fileInfo->getFileName();
            $fixedFileName = str_replace('- ', ': ', $fileName); // Because sketchtool replaces ':' with '-' we need to return original mane back.
            rename($path, $tempfile . '/' . $fixedFileName);
        }

        rmdir($outDir);
    }

    private function getSlicesToExport($JSON, $page) {

        $slices = array();
        foreach ($JSON as $value) {
            $pageName = $value['name'];
            if (strlen($page) == 0 || strtolower($page) == strtolower($pageName)) {
                $slicesArray = $value['slices'];
                foreach ($slicesArray as $slice) {
                    $slices[] = $slice['name'];
                }
            }
        }

        return $slices;
    }

    private function getSketchDocumentSlices($inputPath) {
        $JSONString = $this->executeCommand("sketchtool list slices \"$inputPath\"");
        $JSON = json_decode($JSONString, true);
        return $JSON['pages'];
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


    private function collectImageSets($inputPath) {
        $directoryIterator = new DirectoryIterator($inputPath);
        // Expected format: "Asset Name@Zx.ext"
        $regexIterator = new RegexIterator($directoryIterator, '/^(.+)@([\d]x)\.(png|jpg|tiff)$/i', RegexIterator::GET_MATCH);
        $imageSets = array();
        foreach ($regexIterator as $match) {
            $image = new Image($match[1], $match[2], $match[3]);
            if (array_key_exists($image->getName(), $imageSets)) {
                $existedImageSet = $imageSets[$image->getName()];
                $existedImageSet->addImage($image);
            } else {
                $imageSet = new ImageSet($image->getName());
                $imageSet->addImage($image);
                $imageSets[$image->getName()] = $imageSet;
            }
        }

        return $imageSets;
    }

    private function doExportAppIconSet($exportDir, $imageSets) {
        $outputDirectoryPath = $this->outputPath . '/' . 'AppIcon.appiconset';
        if (!file_exists($outputDirectoryPath)) {
            mkdir($outputDirectoryPath, 0777, true);
        }

        foreach ($imageSets as $imageName => $imageSet) {
            $imageSetImages = $imageSet->getImages();
            foreach ($imageSetImages as $image) {
                $sourceFile = $exportDir . '/' . $image->getFullName();
                $destinationFile = $outputDirectoryPath . '/' . $image->getFullName();

                $this->log->info(sprintf("Copying file \"%s\"...", $image->getFullName()));
                if (!copy($sourceFile, $destinationFile)) {
                    $this->log->error(sprintf("Unable to copy from \"%s\" to \"%s\".", $sourceFile, $destinationFile));
                    exit (1);
                }
            }
        }
    }

    private function doExport($inputPath, $outputPath, $imageSets) {

        foreach ($imageSets as $imageName => $imageSet) {
            $outputDirectoryPath = $outputPath . '/' . $imageName . '.imageset';

            $components = array();
            // Searching for category name
            // Expected images in naming format: "Category: Asset Name@Zx.ext"
            $status = preg_match('/^(.+)\:\s+(.+)$/i', $imageName, $components);
            if ($status == 1) {
                $folderName = $components[1];
                $assetName = $components[0] . '.imageset';

                $outputDirectoryPath = $outputPath . '/' . $folderName . '/' . $assetName;
            }

            if (!file_exists($outputDirectoryPath)) {
                mkdir($outputDirectoryPath, 0777, true);
            }

            $configFile = $outputDirectoryPath . '/Contents.json';
            if (!file_exists($configFile)) {
                $this->log->info("Writing default \"Contents.json\" file.");
                file_put_contents($configFile, $imageSet->toJson());
            }

            $imageSetImages = $imageSet->getImages();
            foreach ($imageSetImages as $image) {
                $sourceFile = $inputPath . '/' . $image->getFullName();
                $destinationFile = $outputDirectoryPath . '/' . $image->getFullName();

                $this->log->info(sprintf("Copying file \"%s\"...", $image->getFullName()));
                if (!copy($sourceFile, $destinationFile)) {
                    $this->log->error(sprintf("Unable to copy from \"%s\" to \"%s\".", $sourceFile, $destinationFile));
                    exit (1);
                }
            }
        }
    }
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
        return $this->name . '@' . $this->scale . '.' . $this->extension;
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

    function getImages() {
        return $this->images;
    }

}

?>
