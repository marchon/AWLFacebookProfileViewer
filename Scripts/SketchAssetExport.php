<?php

include('Logger.php');
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
    performSlicesExport(realpath($inputPath), realpath($outputPath), $page);
} else {
    echo usageString();
}

$logger->info("Export completed.");
exit(0);

function performSlicesExport($inputPath, $outputPath, $page) {

    $JSON = readSketchDocument($inputPath);
    $slices = getSlicesToExport($JSON, $page);
    exportAndMaintainSlices($slices, $inputPath, $outputPath);
}


function exportAndMaintainSlices($slices, $inputPath, $outputPath) {
    $log = Logger::getLogger("export");
    $argItems = implode(', ', $slices);

    $tempfile = tempnam(sys_get_temp_dir(), 'sketch-export-');
    if (file_exists($tempfile)) { unlink($tempfile); }
    mkdir($tempfile);

    $outputLines = '';
    $returnCode = 0;
    $cmd = "sketchtool export slices \"$inputPath\" --output=\"$tempfile\" --items=\"$argItems\" --formats=\"png\" --scales=\"0.5, 1.0, 1.5\" --overwriting=YES --save-for-web=YES";
    exec($cmd, $outputLines, $returnCode);
    if ($returnCode != 0) {
        $log->error("Unable to execute command '$cmd'");
        exit(1);
    }

    fixFileNames($tempfile);
    performExport($tempfile, $outputPath);

    // Cleanup
    $directoryIterator = new DirectoryIterator(sys_get_temp_dir());
    // Expected format: "Asset Name@Zx.ext"
    $regexIterator = new RegexIterator($directoryIterator, '/^sketch-export-.+/i', RegexIterator::MATCH);
    foreach($regexIterator as $match) {
        $dirName = $match->getPathname();
        system("rm -rf ".escapeshellarg($dirName));
    }
}

function fixFileNames($tempfile) {

    $outDir = "$tempfile/renamed";
    mkdir($outDir, 0777, true);

    $flags = FilesystemIterator::KEY_AS_PATHNAME | FilesystemIterator::CURRENT_AS_FILEINFO | FilesystemIterator::SKIP_DOTS | FilesystemIterator::UNIX_PATHS;
    $directoryIterator = new FilesystemIterator($tempfile, $flags);
    foreach($directoryIterator as $path => $fileInfo) {

        if ($fileInfo->isDir()) {
            continue;
        }

        $extension = $fileInfo->getExtension();
        $baseName = $fileInfo->getBasename('.'.$extension);
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
        $destination = $outDir.'/'.$nameComponents[0].$newScaleFactor.'.'.$extension;
        rename($path, $destination);
    }

    $directoryIterator = new FilesystemIterator($outDir, $flags);
    foreach($directoryIterator as $path => $fileInfo) {
        if ($fileInfo->isDir()) {
            continue;
        }
        $fileName = $fileInfo->getFileName();
        $fixedFileName = str_replace('- ', ': ', $fileName); // Because sketchtool replaces ':' with '-' we need to return original mane back.
        rename($path, $tempfile.'/'.$fixedFileName);
    }

    rmdir($outDir);

}

function getSlicesToExport ($JSON, $page) {

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

function readSketchDocument($inputPath) {
    $log = Logger::getLogger("read");

    $outputLines = '';
    $returnCode = 0;
    $cmd = "sketchtool list slices \"$inputPath\"";
    exec($cmd, $outputLines, $returnCode);
    if ($returnCode != 0) {
        $log->error("Unable to execute command '$cmd'");
        exit(1);
    }

    $JSONString = implode('', $outputLines);
    $JSON = json_decode($JSONString, true);
    return $JSON['pages'];
}


function collectImageSets($inputPath) {
    $directoryIterator = new DirectoryIterator($inputPath);
    // Expected format: "Asset Name@Zx.ext"
    $regexIterator = new RegexIterator($directoryIterator, '/^(.+)@([\d]x)\.(png|jpg|tiff)$/i', RegexIterator::GET_MATCH);
    $imageSets = array();
    foreach($regexIterator as $match)
    {
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

function performExport($inputPath, $outputPath) {
    $logger = Logger::getLogger("export");
    $imageSets = collectImageSets($inputPath);

    foreach ($imageSets as $imageName => $imageSet) {
        $outputDirectoryPath = $outputPath.'/'.$imageName.'.imageset';

        $components = array();
        // Searching for category name
        // Expected images in naming format: "Category: Asset Name@Zx.ext"
        $status = preg_match('/^(.+)\:\s+(.+)$/i', $imageName, $components);
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

        $imageSetImages = $imageSet->getImages();
        foreach ($imageSetImages as $image) {
            $sourceFile = $inputPath.'/'.$image->getFullName();
            $destinationFile = $outputDirectoryPath.'/'.$image->getFullName();

            $logger->info(sprintf("Copying file \"%s\"...", $image->getFullName()));
            if (!copy ($sourceFile, $destinationFile)) {
                $logger->error(sprintf("Unable to copy from \"%s\" to \"%s\".", $sourceFile, $destinationFile));
                exit (1);
            }
        }
    }
}

function usageString() {
    $usage = "Usage: php ".basename(__FILE__).' -i <document> -o <path> [ --page=<string> ]';
    return $usage."\n";
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

    function getImages() {
        return $this->images;
    }

}

?>