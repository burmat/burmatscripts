<?php

	$count = 1;

	// open the list of file names
	$file = fopen('file_list.txt', 'r');

	// while iterating
	while (!feof($file)) {

		//if ($count > 5) { break; } // for testing, no need to iterate 5,000

		// get the filename, trim off \r\n chars, and echo it
		$filename = rtrim(fgets($file));
		echo $count . ") " . $filename . "\n";

		// form our http:// link to pdf file, download the pdf
		$pdf_path = "http://burmat.co/pdfs/" . $filename;
		file_put_contents($filename, fopen($pdf_path, 'r'));

		// gererate our filename for our image
		$img_filename = str_replace('.pdf', '-preview.png', $filename);

		// generate our imagick object to get the first page of pdf file downloaded
		$im = new imagick($filename.'[0]'); // 0 = page 1, 1 = page 2, etc..
		$im->setImageFormat('png');
		$im->thumbnailImage(350, 0); // kinda works?
		//$im->setResolution(350, 0);

		// put the image in a directory for safe-keeping
		file_put_contents('img/' . $img_filename, $im);

		// delete the pdf file you just downloaded
		unlink($filename);

		// iterate the counter
		$count++;

	}
?>
