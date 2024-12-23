function RenderElements()
{
    //Hide all elements
    //$('.panel-body').hide();

	$('#RatingsSection1').hide();
	$('#RatingsSection2').hide();
	$('#RatingsSection3').hide();

	if ($("#RatingsSection4").length) { $("#RatingsSection4").hide(); }

	//Initialize rating starts

    for (var i = 0; i < QuestionDetails.length; i++) {
    	QueAns[QuestionDetails[i].QuestionId] = QuestionDetails[i].CustRatings;

    	var overAllRatingSize = 'md';
    	var subRatingSize = 'xxs';
    	var captionId = '#Caption_' + QuestionDetails[i].QuestionId;
    	var captionClass = 'RatingValueText';

    	if (UserAgent == 'MOBILE') {
    		overAllRatingSize = 'md';
    		subRatingSize = 'xs';
    		captionId = '';
    		captionClass = 'MobRatingValueText';
    	}

    	if (QuestionDetails[i].Weightage != 1) {
    		$('#input-' + QuestionDetails[i].QuestionId).rating({
    			showClear: false,
    			showCaption: true,
    			captionElement: captionId,
    			size: subRatingSize,
    			step: 1,
    			starCaptions: {0:'Not Rated', 1: 'Very Poor', 2: 'Poor', 3: 'Okay', 4: 'Good', 5: 'Very Good'},
    			starCaptionClasses: { 0: captionClass, 1: captionClass, 2: captionClass, 3: captionClass, 4: captionClass, 5: captionClass },
    			hoverEnabled: true,
    			hoverChangeCaption: false
    		});

    		UpdateColorBasedOnValue($('#input-' + QuestionDetails[i].QuestionId), QuestionDetails[i].CustRatings);
    	}
    	else {
    		$('#input-' + QuestionDetails[i].QuestionId).rating({
    			showClear: false,
    			showCaption: true,
    			captionElement: captionId,
    			size: overAllRatingSize,
    			step: 1,
    			starCaptions: { 0: 'Not Rated', 1: 'Very Poor', 2: 'Poor', 3: 'Okay', 4: 'Good', 5: 'Very Good' },
    			starCaptionClasses: { 0: captionClass, 1: captionClass, 2: captionClass, 3: captionClass, 4: captionClass, 5: captionClass },
    			hoverEnabled: true,
    			hoverChangeCaption: false
    		});

    		UpdateColorBasedOnValue($('#input-' + QuestionDetails[i].QuestionId), QuestionDetails[i].CustRatings, true);
    	}
    }

    if (supportedLanguage.length <= 1)
    {
    	$('.dropdown').hide();
    }
	else
	{
		//Initialize language
		for(var i=0; i<supportedLanguage.length; i++)
		{
			$('#languageSelector').append('<option id = "'+supportedLanguage[i].LanguageName+'" ><span class="tab">' + supportedLanguage[i].LanguageDisplayName + '</span></option>');
		}

		$("#languageSelector option[id='" + defaultLanguage.toUpperCase() + "']").attr('selected', true);
	}

    $('.language').hide();

	//Display default language
    $('.' + defaultLanguage).show();

    //if valid ticket
	if(status == "INVALID_RATING")
	{
		$('#InvalidRating').show();
	}
	
    if(status == "VALID" || status == "NOT_SUBMITTED")
    {
        //Take a survey
    	$('#RatingsSection1').show();
    	$('#RatingsSection2').show();
    	$('#RatingsSection3').show();

    	if ($("#RatingsSection4").length) { $("#RatingsSection4").show(); }
    }
    else if(status == "SUBMITTED")
    {
    	//Already submitted ratings
    	$('#RatingsSection1').hide();
    	$('#RatingsSection2').hide();
    	$('#RatingsSection3').hide();
    	if ($("#RatingsSection4").length > 0) { $("#RatingsSection4").hide(); }
        $('#RatingReviewsExist').show();
    }
    else if(status == "NO_DATA")
    {
    	//For TIN data is not available     
    	$('#RatingsSection1').hide();
    	$('#RatingsSection2').hide();
    	$('#RatingsSection3').hide();
    	if ($("#RatingsSection4").length > 0) { $("#RatingsSection4").hide(); }
        $('#ErrorMessage').show();
    }
    else if (status == "EXPIRED") {
        $('#ErrorMessage').hide();
        $('#ExpiredMessage').show();
    }
    else
    {
    	//Take input from user (tin, emailid, mobile no)
    	$('RatingsSection1').hide();
    	$('RatingsSection2').hide();
    	$('RatingsSection3').hide();
        $('#ErrorMessage').show();
    }
    ChangeLanguage();
	//hide alert containers
	$('#alert_template .close').click(function(e) {$("#alert_template").hide(); $("#alert_template span").remove();});  
}

function ValidateRatingsInput()
{
    var IsValidData = true;

    for(var i=0; i<QuestionDetails.length; i++)
    {
        if((QueAns[QuestionDetails[i].QuestionId] == null || QueAns[QuestionDetails[i].QuestionId] <= 0) && QueAns[QuestionDetails[i].QuestionId] != OverAllQuestionId)
        {	
            IsValidData = false;
        }
    }	

	if(!IsValidData)
	{
		showalert('Please Provide Ratings.');
	}

    return IsValidData;
}

function showalert(message) 
{
	$("#alert_template button").nextAll().remove();
    $("#alert_template button").after('<span>' + message + '</span>');
    $('#alert_template').show();

    setTimeout(function() { $("#alert_template").hide(); $("#alert_template span").remove();}, 5000);  
} 

function SubmitFeedback()
{
    $("#SubmitFB").attr("disabled", true);

    if(ValidateRatingsInput())
    {
		OverAllRating   =   0;

		//Calculate overall rating according to question weightage
        if(OverAllQuestionId)
        {
            for(var i =0; i <QuestionDetails.length; i++)
            {
                if(QuestionDetails[i].Weightage != 1)
                {
                    OverAllRating   =   OverAllRating   +   QueAns[QuestionDetails[i].QuestionId] * QuestionDetails[i].Weightage;
                }            
            } 
			
			QueAns[OverAllQuestionId]	=	Math.round(OverAllRating);

		}

		//Update over all rating with the updated value
        for(var i =0; i<response.RatingResposne.length; i++)
        {
            response.RatingResposne[i].CustResposneValue    =   QueAns[response.RatingResposne[i].QuestionId]
        }	

        var languageselected = $("#languageSelector option:selected").length > 0 ? $("#languageSelector option:selected")[0].id.toLowerCase() : "en";

        response.Reviews = $('#CustReview_' + languageselected).val();

        $.post("/RatingReviews/SubmitFeedBack", { "resposne": response }, function (data) 
        {
            if(data.Message == "SUCCESS")
            {
                //$('.panel-body').hide();
            	$('#RatingsSection1').hide();
            	$('#RatingsSection2').hide();
            	$('#RatingsSection3').hide();

            	if ($("#RatingsSection4").length) { $("#RatingsSection4").hide(); }

            	$('#ThankYou').show();
            }
            else
            {
                //$('.panel-body').hide();
            	$('#RatingsSection1').hide();
            	$('#RatingsSection2').hide();
            	$('#RatingsSection3').hide();

            	if ($("#RatingsSection4").length) { $("#RatingsSection4").hide(); }

            	if (data.Message == "EXPIRED") {
            	    $("#ExpiredMessage").show();
            	}
            	else {
            	    $('#ErrorMessage').show();
            	}
            }
        });  
    }       
}

function UpdateColorBasedOnValue(ele, value, isOverAllRating)
{
	if(isOverAllRating)
	{
		ele.siblings().find('.filled-stars').css( "color", "#FFDC4F" );
	}
	else
	{
		if(value > 3)
		{
			ele.siblings().find('.filled-stars').css( "color", "#01fcce" );
		}
		else if(value < 3)
		{
			ele.siblings().find('.filled-stars').css( "color", "#FA5136" );
		}
		else
		{
			ele.siblings().find('.filled-stars').css( "color", "#FFDC4F" );
		} 
	}	
}

function ChangeLanguage()
{
	var language = $("#languageSelector option:selected").length > 0 ? $("#languageSelector option:selected")[0].id : "en";
	$('.language').hide();
	$('.' + language.toLowerCase()).show();
	PopulateRatings(language.toLowerCase());

	$('.ratingStar').on('rating.change', function (event, value, caption) {
		var QID = this.getAttribute("data-QId");

		//update QueAns with updated value
		QueAns[QID] = value;

		//If over all rating got changed then update others with that value
		if (QID == OverAllQuestionId) {
			for (var i = 0; i < QuestionDetails.length; i++) {
				if (QuestionDetails[i].QuestionId != OverAllQuestionId) {
					//Upadte all ans if user clicks on ver all ratings
					QueAns[QuestionDetails[i].QuestionId] = value;
					$('#input-' + QuestionDetails[i].QuestionId).rating('update', value);

					//update the color
					UpdateColorBasedOnValue($('#input-' + QuestionDetails[i].QuestionId), value);
				}
			}
		}
		else {
			UpdateColorBasedOnValue($(this), value);
		}

	});

}

function GetLanguageSpecificRating(lang)
{
	switch(lang)
	{
		case "en": return { 0: 'Not Rated', 1: 'Very Poor', 2: 'Poor', 3: 'Okay', 4: 'Good', 5: 'Very Good' };
			break;
		case "es": return { 0: 'Sin Clasificar', 1: 'Muy Malo', 2: 'Malo', 3: 'Normal', 4: 'Bueno', 5: 'Muy Bueno' };
			break;
		case "id": return { 0: 'Not Rated', 1: 'Very Poor', 2: 'Poor', 3: 'Okay', 4: 'Good', 5: 'Very Good' };
			break;
		case "vi": return { 0: 'Not Rated', 1: 'Very Poor', 2: 'Poor', 3: 'Okay', 4: 'Good', 5: 'Very Good' };
			break;
		default: return { 0: 'Not Rated', 1: 'Very Poor', 2: 'Poor', 3: 'Okay', 4: 'Good', 5: 'Very Good' };
			break;
	}
}

function PopulateRatings(lang)
{
	var starRatings = GetLanguageSpecificRating(lang);

	for (var i = 0; i < QuestionDetails.length; i++) {

		$('#input-' + QuestionDetails[i].QuestionId).rating('refresh',{
				starCaptions: starRatings
		});

		if (QuestionDetails[i].Weightage != 1)
			UpdateColorBasedOnValue($('#input-' + QuestionDetails[i].QuestionId), QueAns[QuestionDetails[i].QuestionId]);
		else
			UpdateColorBasedOnValue($('#input-' + QuestionDetails[i].QuestionId), QueAns[QuestionDetails[i].QuestionId], true);
	}

}