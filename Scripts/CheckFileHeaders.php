<?php

// Usage: php CheckFileHeaders.php /path/to/project/directory ProjectName

if (!defined('TEST')) {
    main();
}

function main ()
{
    // Checking input directory
    $srcDirectory = '';
    $srcProjectName = '';
    if(count($_SERVER['argv']) > 2) {
        $srcDirectory   = $_SERVER['argv'][1];
        $srcProjectName = $_SERVER['argv'][2];
    }

    if(!file_exists($srcDirectory)) {
        echo 'warning: Directory is not exists: "'.$srcDirectory.'"';
        exit();
    }

    if(!is_dir($srcDirectory)) {
        echo 'warning: Argument is not a directory: "'.$srcDirectory.'"';
        exit();
    }

    if(empty($srcProjectName)) {
        echo 'warning: Project name is missed';
        exit();
    }

    // Searching for header and implementation files
    $filesToProcess = array();
    $allFilesIterator = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($srcDirectory));
    $regexIterator = new RegexIterator($allFilesIterator, '/^.+\.(h|m|mm|swift)$/i', RecursiveRegexIterator::GET_MATCH);
    foreach($regexIterator as $match) {
        $filesToProcess[] = $match[0];
    }

    if(empty($filesToProcess)) {
        echo 'warning: Unable to find any file with extension "h|m|mm" to process';
        exit();
    }

    // Getting files with incorrect header
    $filesWithIncorrectHeader = array();
    foreach($filesToProcess as $filePath) {
        $basename = basename($filePath, ".swift");
        if (strcmp(substr($basename, -8), "StyleKit") == 0) {
            continue;
        }
        $errorLine = lineNumberOfError($filePath, $srcProjectName);
        if($errorLine != -1) {
            $filesWithIncorrectHeader[] = array($filePath, $errorLine);
        }
    }

    // Report results
    function printWarning($element, $index) {
        echo $element[0].':'.$element[1].': warning: Incorrect file header in '.basename($element[0])."\n";
    }
    
    array_walk($filesWithIncorrectHeader, 'printWarning');
    
//    $numFilesWithErrors = count($filesWithIncorrectHeader);
//    if($numFilesWithErrors > 0) {
//        echo count($filesWithIncorrectHeader)." file(s) with incorrect header found\n";
//    }
}

function lineNumberOfError($sFilePath, $sProjectName) {
    $contents = file_get_contents($sFilePath, false, NULL, -1, 256); // Reading first 256 symbols
    $contents = trim($contents);
    if(substr_compare($contents, "///", 0, 3) == 0) {
        return lineNumberOfErrorForNewHeader($sFilePath, $sProjectName, $contents);
    } else {
        return lineNumberOfErrorForOldHeader($sFilePath, $sProjectName, $contents);
    }
}

function lineNumberOfErrorForNewHeader($sFilePath, $sProjectName, $sFileContents) {
    // Get header
    $aLines = preg_split("/[\n\r]+/", $sFileContents);
    $aHeader = array();
    foreach($aLines as &$sLine) {
        if(substr_compare($sLine, "///", 0, 3) == 0) {
            $aHeader[] = $sLine;
        } else {
            break;
        }
    }
    unset($aLines, $sLine);

    if(count($aHeader) != 4) { // Checking header size
        return 1;
    }


    if(isValidFileName($aHeader[0], $sFilePath) == false) { return 1; }
    if(isValidProjectName($aHeader[1], $sProjectName) == false) { return 2; }
    if(isValidAuthor($aHeader[2]) == false) { return 3; }
    if(isValidCopyright($aHeader[3]) == false) { return 4; }

    return -1;
}

function isValidFileName($sHeaderLine, $sFilePath) {
    if(!preg_match('/( \* |\/\/\/ )File:\s([\w\.\+\-]+)/s', $sHeaderLine, $aMatches)) {
        return false;
    }
    $sFileNameFromHeader = $aMatches[2];
    $sFileNameReal = basename($sFilePath);
    if(strcmp($sFileNameFromHeader, $sFileNameReal) != 0) {
        return false;
    }
    return true;
}

function isValidProjectName($input, $projectName) {

    if(!preg_match('/( \* |\/\/\/ )Project:\s(\w+)/s', $input, $matches)) {
        return false;
    }

    $projectNameFromHeader = $matches[2];
    if(strcmp($projectNameFromHeader, $projectName) != 0) {
        return false;
    }

    return true;
}

function isValidAuthor($input) {

    if(!preg_match('/( \* |\/\/\/ )Author:\s[\w\W]+?by\s([\w\s]+?)\son\s([\w\W]+)\./s', $input, $matches)) {
        return false;
    }
    $author = $matches[2];
    $words = explode(" ", $author);
    if(count($words) != 2) {
        return false;
    }
    return true;
}

function isValidCopyright($input) {
    if(!preg_match('/( \* |\/\/\/ )Copyright:\s[\w\W]+/s', $input, $matches)) {
        return false;
    }
    return true;
}

function lineNumberOfErrorForOldHeader($filePath, $projectName, $contents) {
    
    // Getting header
    if(!preg_match('/\/\*\*.+\*\//s', $contents, $matches)) {
        return 1;
    }
    $header = $matches[0];
    
    // Checking header size
    $lines = preg_split("/[\n\r]+/", $header);
    if(count($lines) != 7) {
        return 1;
    }
    
    if(isValidFileName($lines[1], $filePath) == false) { return 2; }
    if(isValidProjectName($lines[2], $projectName) == false) { return 3; }
    if(isValidAuthor($lines[4]) == false) { return 5; }
    if(isValidCopyright($lines[5]) == false) { return 6; }
    
    return -1;
}

?>