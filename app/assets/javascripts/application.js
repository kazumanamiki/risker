// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require jquery.ui.all

var ready = function() {
	// datetimepikerのスクリプト
	$('input.datepicker').datepicker({
		dateFormat: 'yy-mm-dd',
		yearSuffix: '年',
		monthNames: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'],
		dayNamesMin: ['日', '月', '火', '水', '木', '金', '土'],
		minDate: new Date()
	});
	$('button.modal-cancel').click(function(){
		$(this).closest("form")[0].reset();
	});
};
$(document).ready(ready)
$(document).on('page:load', ready)
