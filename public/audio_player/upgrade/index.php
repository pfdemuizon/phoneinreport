<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>1 Pixel Out Audio Player Upgrade wizard</title>
<script type="text/javascript">
self.focus();
</script>
<style type="text/css">
body {
	margin:0;
	padding:0 0 0 211px;
	font:70% "Trebuchet MS", Verdana, Helvetica, sans-serif;
	background:#357DCE url(background.jpg) no-repeat top left;
}
#main {
	margin-left:1px;
	padding:20px;
	background:#fff;
	height:196px;
}
h1 {
	margin:0 0 2em 0;
	font-size:1.2em;
}
ul {
	list-style-type:none;
	margin:0;
	padding:0;
	border-top:1px solid #ddd;
}
ul li {
	padding:0.5em 0;
	color:#ccc;
	border-bottom:1px solid #ddd;
}
ul li.doing {
	color:#000;
}
ul li.done {
	background:url(tick.gif) no-repeat center right;
	padding-right:20px;
	color:#000;
}
ul li.error {
	background:url(error.gif) no-repeat center right;
	padding-right:20px;
	color:#c30;
	font-weight:bold;
}
ul li#step4.done { font-weight:bold; }
p#error { display:none; }
form {
	margin:0;
	padding:0;
	float:right;
}
form input {
	font:1em Verdana, Helvetica, sans-serif;
	margin:8px 8px 8px 0;
}
</style>
</head>

<body>

<div id="main">

<?php if( !isset( $_POST["upgrade"] ) ) { ?>

<h1>Welcome to the 1 Pixel Out Audio Player plugin upgrade wizard</h1>
<p>This tool will download and install the latest version of the <strong>Audio Player</strong>. Be aware that upgrading
the plugin will overwrite the current version of <strong>Audio Player</strong>. To continue click <strong>Upgrade</strong>.</p>

<?php } else { ?>

<h1>Upgrading Audio Player plugin</h1>

<ul>
	<li id="step1" class="doing">Downloading archive...</li>
	<li id="step2">Extracting archive...</li>
	<li id="step3">Deleting archive...</li>
	<li id="step4">Upgrade complete!</li>
</ul>

<p id="error">Failed to download update. Please try again later.</p>

<?php } ?>

</div>
<form action="index.php" method="post">
<?php if( !isset( $_POST["upgrade"] ) ) { ?>
	<input type="submit" name="upgrade" value="Upgrade &raquo;" />
	<input type="button" name="close" onclick="self.close()" value="Cancel" />
<?php } else { ?>
	<input type="button" name="close" onclick="self.close()" value="Finish" />
<?php } ?>
</form>

<?php

if( isset( $_POST["upgrade"] ) ) {

ob_flush();
flush();

$ap_archiveURL = "http://www.1pixelout.net/download/audio-player.zip";
$target = fopen( "audio-player.zip", "wb" );
$filecontents = "";

if( function_exists( "curl_init" ) ) {
	$source = curl_init();
	curl_setopt( $source, CURLOPT_URL, $ap_archiveURL );
	curl_setopt( $source, CURLOPT_CONNECTTIMEOUT, 10 );
	curl_setopt( $source, CURLOPT_FAILONERROR, 1 );
	curl_setopt( $source, CURLOPT_RETURNTRANSFER, 1 );
	$filecontents = curl_exec( $source );
	if( curl_errno( $source ) > 0 ) {
		$filecontents = "error";
	} else curl_close( $source );
} else if( ini_get( "allow_url_fopen" ) ) {
	if( $source = @fopen( $ap_archiveURL, "rb" ) ) {
		while( !feof( $source ) ) {
			$filecontents .= fread( $source, 8192 );
		}
		fclose($source);
	} else $filecontents = "error";
}

if( $filecontents == "error" ) { ?>

<script type="text/javascript">
document.getElementById( "step1" ).className = "error";
document.getElementById( "error" ).style.display = "block";
</script>

<?php } else {

fwrite( $target, $filecontents );
fclose( $target );

?>

<script type="text/javascript">
document.getElementById( "step1" ).className = "done";
document.getElementById( "step2" ).className = "doing";
</script>

<?php

ob_flush();
flush();

if($zip = zip_open(dirname(__FILE__) . "/audio-player.zip")) {
	while($zip_entry = zip_read($zip)) {
		if (zip_entry_open($zip, $zip_entry, "r")) {
			$file = zip_entry_name($zip_entry);
			
			$dirpath = "";
			
			foreach( explode("/", dirname($file)) as $dir ) {
				$dirpath .= $dir . "/";
				if( !file_exists("../../" . $dirpath ) ) mkdir("../../" . $dirpath );
			}
			
			$stream = fopen("../../" . $file, "w");
			fwrite($stream, zip_entry_read($zip_entry, zip_entry_filesize($zip_entry)));
			fclose($stream);
			
			zip_entry_close($zip_entry);
		}
		
	}
	
	zip_close($zip);
}

?>

<script type="text/javascript">
document.getElementById( "step2" ).className = "done";
document.getElementById( "step3" ).className = "doing";
</script>

<?php

ob_flush();
flush();

unlink(dirname(__FILE__) . "/audio-player.zip");

?>

<script type="text/javascript">
document.getElementById( "step3" ).className = "done";
document.getElementById( "step4" ).className = "done";
</script>

<?php

ob_flush();
flush();

}

}

?>

</body>
</html>

<?php ob_flush(); ?>