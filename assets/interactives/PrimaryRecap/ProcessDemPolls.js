var AWS = require('aws-sdk');
var request = require('request')
var s3 = new AWS.S3();
/*
s3.getObject({Bucket: 'HuffPoPollsterDump', Key: 'DemPrimaryPages.json'}).on('success', function(err, response) {
  console.log("Body is", response);
}).send();
*/
request({
        url: "https://s3.amazonaws.com/HuffPoPollsterDump/DemPrimaryPages.json",
        json: true
    }, function(error, response, body){
    	console.log("body[0].questions[0].subpopulations")
       	console.log(body[0].questions[0].subpopulations[0].responses);
    }, function(error){
        
 	}
)
