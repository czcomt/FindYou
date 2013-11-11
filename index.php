<?php

$type = $_POST["type"];

if ($type == 'search_name') {
	$input = $_POST["name"];

	$file=fopen("hello.c","r");

	$count = 0;
	$names = array();

	while (!feof($file)) {
		$text = fgets($file);
		$names[$count] = $text;
  		$count += 1;
	}

	echo "search_name\n";

	for ($i = 0; $i < $count; $i++) {
		$result = strstr($names[$i], $input);
	
		if ($result) {
			echo $names[$i];
		}
	}
	
	fclose($file);
}
else if ($type == 'search_all_image') {
	
	echo "search_all_image\n";
	
	$input = $_POST["name"];
	$pre = "faces/";
	$file_name = "/info.ini";
	$path = $pre . $input . $file_name;
	
	$file=fopen($path, "r");
	
	while (!feof($file)) {
		$text = fgets($file);
		echo $text;
	}
	
	fclose($file);
}
else if ($type == 'search_face') {
	echo "search_face\n";
	$input = $_POST["name"];
	
	$file=fopen("photo.ini", "r");
	
	while (!feof($file)) {
		$file_path = fgets($file);
		$face = fgets($file);
		
		if ($file_path == $input) {
			echo $face;
			break;
		}
	}
	
	echo $aa;
	
	fclose($file);
}
else {
	echo "wrong answer";
}


?>
