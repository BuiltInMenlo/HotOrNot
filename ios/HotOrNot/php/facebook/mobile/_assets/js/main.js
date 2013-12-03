/*
Initialize
*/
$(function() {
	$('.send_to_mobile').on('click', function(e){
		e.preventDefault();
		$('.send_dialog').toggle();
		e.stopPropagation();
	});
	
	$('.send_dialog form').on('submit', function(){
		$('.send_dialog').hide();
	});
	
	$('.send_dialog').on('click', function(e){
		e.stopPropagation();
	});
	
	$(this).on('click', function(e){
		$('.send_dialog').hide();
	});
});