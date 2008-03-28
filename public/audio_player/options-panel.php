<div class="wrap" style="height:100%">
	<h2>Audio player options</h2>
	<?php if( function_exists( "curl_init" ) || ini_get( "allow_url_fopen" ) ) { ?>
	<form style="float:right;margin:0 0 0 10px;" method="post" class="submit"><input type="submit" class="button" name="ap_updateCheck" value="Check for updates" /></form>
	<?php } ?>
	<p>Settings for the Audio Player plugin. Visit <a href="<?php echo $ap_docURL; ?>">1 Pixel Out</a> for usage information and project news.</p>
	<p>Current version: <strong><?php echo $ap_version; ?></strong><?php if( !function_exists( "curl_init" ) && !ini_get( "allow_url_fopen" ) ) { ?> (Visit <a href="<?php echo $ap_docURL; ?>">1 Pixel Out</a> to check for updates)<?php } ?></p>
	<form method="post">
	<fieldset class="options">
		<legend>Audio file location</legend>
		<p>If you use the <code>[audio]</code> syntax, the plugin will assume that all your audio files are located in this folder. The path is relative
		to your blog root. This option does not affect your RSS enclosures or audio files with absolute URLs.</p>
		<table class="editform" cellpadding="5" cellspacing="2" width="100%">
			<tr>
				<th width="33%" valign="top"><label for="ap_audiowebpath">Audio files directory:</label></th>
				<td>
					<input type="text" id="ap_audiowebpath" name="ap_audiowebpath" size="40" value="<?php echo( get_option("audio_player_web_path") ); ?>" /><br />
					Recommended: <code>/audio</code>
				</td>
			</tr>
		</table>
	</fieldset>

	<fieldset class="options">
		<legend>How do you want to use the audio player?</legend>
			<p>This set of options allows you to customize when your audio players appear.</p>
			<ul>
				<li>
					<label for="ap_behaviour_default">
					<input type="checkbox" name="ap_behaviour[]" id="ap_behaviour_default" value="default"<?php if(in_array("default", $ap_behaviour)) echo ' checked="checked"'; ?> />

					<strong>Replace <code>[audio]</code> syntax</strong> (recommended for beginners)</label><br />
					This is the default behaviour and is the only way to apply runtime options to a player instance. Use this option if you want to have more than one audio player per posting.
				</li>
				<li>
					<label for="ap_behaviour_enclosure">
					<input type="checkbox" name="ap_behaviour[]" id="ap_behaviour_enclosure" value="enclosure"<?php if(in_array("enclosure", $ap_behaviour)) echo ' checked="checked"'; ?> />
					<strong>Enclosure integration</strong></label> (for podcasters) <br />
					Ideal for podcasting. If you set your enclosures manually, this option will automatically insert a player at the end of posts with an mp3 enclosure. The player will appear at the bottom of your posting.
				</li>
				<li>
					<label for="ap_behaviour_links">
					<input type="checkbox" name="ap_behaviour[]" id="ap_behaviour_links" value="links"<?php if(in_array("links", $ap_behaviour)) echo ' checked="checked"'; ?> />
					<strong>Replace all links to mp3 files</strong></label><br />
					When selected, this option will replace all your links to mp3 files with a player instance. Be aware that this could produce odd results when links are in the middle of paragraphs.
				</li>
			</ul>
	</fieldset>

	<fieldset class="options">
		<legend>Pre and Post appended audio clips</legend>
		<p>You may wish to pre-append or post-append audio clips into your players. The pre-appended audio will be played before the main audio, and the post-appended will come after. A typical podcasting use-case for this feature is adding a sponsorship message or simple instructions that help casual listeners become subscribers. <strong>This will apply to all audio players on your site</strong>. Your chosen audio clips should be substantially shorter than your main feature.</p>
		<table class="editform" cellpadding="5" cellspacing="2" width="100%">
			<tr>
				<th width="33%" valign="top"><label for="ap_audioprefixwebpath">Pre-appended audio clip URL:</label></th>
				<td>
					<input type="text" id="ap_audioprefixwebpath" name="ap_audioprefixwebpath" size="60" value="<?php echo( get_option("audio_player_prefixaudio") ); ?>" /><br />
					Leave this value blank for no pre-appended audio.
				</td>
			</tr>

			<tr>
				<th width="33%" valign="top"><label for="ap_audiopostfixwebpath">Post-appended audio clip URL:</label></th>
				<td>
					<input type="text" id="ap_audiopostfixwebpath" name="ap_audiopostfixwebpath" size="60" value="<?php echo( get_option("audio_player_postfixaudio") ); ?>" /><br />
					Leave this value blank for no post-appended audio.
				</td>
			</tr>
		</table>
	</fieldset>

	<fieldset class="options">
		<legend>Feed options</legend>
		<p>The following options determine what is included in your feeds. The plugin doesn't place a player instance in the feed. Instead, you can choose what the plugin
		inserts. You have three choices:</p>
		<ul>
			<li><strong>A download link</strong>: Choose this if you are OK with subscribers downloading the file.</li>
			<li><strong>Nothing</strong>: Choose this if you feel that your feed shouldn't contain any reference to the audio file.</li>
			<li><strong>Custom</strong>: Choose this to use your own alternative content for all player instances. You can use this option to tell subscribers that they can listen to the audio file if they read the post on your blog.</li>
		</ul>
		<table class="editform" cellpadding="5" cellspacing="2" width="100%">
			<tr>
				<th width="33%" valign="top"><label for="ap_rssalternate">Alternate content for  feeds:</label></th>
				<td>
					<select id="ap_rssalternate" name="ap_rssalternate">
						<option value="download"<?php if( $ap_rssalternate == 'download' ) echo( 'selected="selected"'); ?>>Download link</option>
						<option value="nothing"<?php if( $ap_rssalternate == 'nothing' ) echo( 'selected="selected"'); ?>>Nothing</option>
						<option value="custom"<?php if( $ap_rssalternate == 'custom' ) echo( 'selected="selected"'); ?>>Custom</option>
					</select>
				</td>
			</tr>
			<tr>
				<th width="33%" valign="top"><label for="ap_rsscustomalternate">Custom  alternate content:</label></th>
				<td>
					<input type="text" id="ap_rsscustomalternate" name="ap_rsscustomalternate" size="60" value="<?php echo( get_option("audio_player_rsscustomalternate") ); ?>" />
				</td>
			</tr>
		</table>
	</fieldset>

	<fieldset class="options">
		<legend>Colour scheme</legend>
		<p>Select a colour to edit and enter the new colour code in the box. The preview player below will reflect the change. Remember to click the <strong>Update options</strong> button when you are done.</p>
		
		<input type="hidden" name="ap_bgcolor" id="ap_bgcolor" value="<?php echo( str_replace( "0x", "#", $ap_options["bg"] ) ); ?>" />
		<input type="hidden" name="ap_leftbgcolor" id="ap_leftbgcolor" value="<?php echo( str_replace( "0x", "#", $ap_options["leftbg"] ) ); ?>" />
		<input type="hidden" name="ap_rightbgcolor" id="ap_rightbgcolor" value="<?php echo( str_replace( "0x", "#", $ap_options["rightbg"] ) ); ?>" />
		<input type="hidden" name="ap_rightbghovercolor" id="ap_rightbghovercolor" value="<?php echo( str_replace( "0x", "#", $ap_options["rightbghover"] ) ); ?>" />
		<input type="hidden" name="ap_lefticoncolor" id="ap_lefticoncolor" value="<?php echo( str_replace( "0x", "#", $ap_options["lefticon"] ) ); ?>" />
		<input type="hidden" name="ap_righticoncolor" id="ap_righticoncolor" value="<?php echo( str_replace( "0x", "#", $ap_options["righticon"] ) ); ?>" />
		<input type="hidden" name="ap_righticonhovercolor" id="ap_righticonhovercolor" value="<?php echo( str_replace( "0x", "#", $ap_options["righticonhover"] ) ); ?>" />
		<input type="hidden" name="ap_textcolor" id="ap_textcolor" value="<?php echo( str_replace( "0x", "#", $ap_options["text"] ) ); ?>" />
		<input type="hidden" name="ap_loadercolor" id="ap_loadercolor" value="<?php echo( str_replace( "0x", "#", $ap_options["loader"] ) ); ?>" />
		<input type="hidden" name="ap_slidercolor" id="ap_slidercolor" value="<?php echo( str_replace( "0x", "#", $ap_options["slider"] ) ); ?>" />
		<input type="hidden" name="ap_trackcolor" id="ap_trackcolor" value="<?php echo( str_replace( "0x", "#", $ap_options["track"] ) ); ?>" />
		<input type="hidden" name="ap_bordercolor" id="ap_bordercolor" value="<?php echo( str_replace( "0x", "#", $ap_options["border"] ) ); ?>" />
		<select id="ap_fieldselector" onchange="ap_selectField(this)">
		  <option value="bg" selected>Background</option>
		  <option value="leftbg">Left background</option>
		  <option value="rightbg">Right background</option>
		  <option value="rightbghover">Right background (hover)</option>
		  <option value="lefticon">Left icon</option>
		  <option value="righticon">Right icon</option>
		  <option value="righticonhover">Right icon (hover)</option>
		  <option value="text">Text</option>
		  <option value="loader">Loaded bar</option>
		  <option value="slider">Slider</option>
		  <option value="track">Progress bar track</option>
		  <option value="border">Progress bar border</option>
		</select>
		<input name="ap_colorvalue" type="text" id="ap_colorvalue" size="15" maxlength="7" onkeypress="ap_updateColors()" />
		
		<br /><br />
		
		<?php echo ap_getplayer(get_option( siteurl ) . "/wp-content/plugins/audio-player/test.mp3", $ap_demo_options); ?>

		<br /><br />
		
		<img src="<?php echo get_option( siteurl ); ?>/wp-content/plugins/audio-player/map.gif" alt="Colour map" width="390" height="124" />

		<p>
			Here, you can set the page background of the player. In most cases, simply select "transparent" and it will
			match the background of your page. In some rare cases, the player will stop working in Firefox if you use the
			transparent option. If this happens, untick the transparent box and enter the color of your page background in
			the box below (in the vast majority of cases, it will be white: #FFFFFF).
		</p>
		<p>
			<label for="ap_pagebgcolor"><strong>Page background color:</strong></label>
			<input type="text" id="ap_pagebgcolor" name="ap_pagebgcolor" size="20" value="<?php echo( get_option("audio_player_pagebgcolor") ); ?>" />
			<input type="checkbox" name="ap_transparentpagebg" id="ap_transparentpagebg" value="true"<?php if( get_option("audio_player_transparentpagebg") ) echo ' checked="checked"'; ?> onclick="ap_setPagebgField()" />
			<label for="ap_transparentpagebg">Transparent</label>
		</p>
	</fieldset>

	<a href="<?php echo $ap_docURL; ?>"><img src="<?php echo get_option("siteurl" ); ?>/wp-content/plugins/audio-player/logo.gif" style="float:left;margin:10px 0 0 5px;" /></a>
	<p class="submit">
		<input name="Submit" value="Update Options &raquo;" type="submit" />
	</p>
	</form>
</div>