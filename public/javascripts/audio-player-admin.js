var ap_colorInput, ap_fieldSelector, ap_selectedField;
window.onload = function() {
	if( !document.getElementById("ap_colorvalue") ) return;
	ap_colorInput = document.getElementById("ap_colorvalue");
	ap_fieldSelector = document.getElementById("ap_fieldselector");
	ap_selectField();
	ap_setPagebgField();
	setInterval( ap_updateColors, 1000 );
}
function ap_selectField() {
	ap_selectedField = ap_fieldSelector.options[ap_fieldSelector.selectedIndex].value;
	ap_colorInput.value = document.getElementById("ap_" + ap_selectedField + "color").value;
}
function ap_updateColors() {
	document.getElementById("ap_" + ap_selectedField + "color").value = ap_colorInput.value;
	var audioplayer = document.getElementById("audioplayer1");
	audioplayer.SetVariable(ap_selectedField, ap_colorInput.value.replace("#", "0x"));
	audioplayer.SetVariable("setcolors", 1);
}
function ap_setPagebgField() {
	var bgField = document.getElementById("ap_pagebgcolor");
	if(document.getElementById("ap_transparentpagebg").checked) {
		bgField.disabled = true;
		bgField.style.color = "#999999";
	} else {
		bgField.disabled = false;
		bgField.style.color = "#000000";
	}
}
function ap_stopAll(a) {
	return;
}
function ap_startUpgradeWizard() {
	var ap_upgrade = window.open( ap_updateURL, "ap_upgrade", "width=500,height=270,status=no" );
}