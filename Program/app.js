var path = require('path');
var favicon = require('serve-favicon');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');

var MongoClient = require('mongodb').MongoClient;
var fs = require('fs');
http = require('http');
var coap = require('coap');

var connectionUrl = 'mongodb://localhost:27017/' , sampleCollection = 'data';
var dbName = 'myproject';

const mongotocsv = require('mongo-to-csv');

var schedule = require('node-schedule');

var j = schedule.scheduleJob('00 00 00 * * *' , async function(){
	console.log('The answer to life, the universe, and everything!');

	var date_for_check = new Date();
	console.log("Date = " + date_for_check.getDate());
	console.log("Month = " + date_for_check.getMonth());

	let option = {
		database: dbName,
		collection: sampleCollection,
		fields: ['created_at' , 'temp' , 'humidity' , 'cds' , 'vol_solar' , 'vol_bat' , 'Amp_solar' , 'Amp_bat'],
		//output: './output/pets.csv',
		output: './output/' + (date_for_check.getMonth() + 1) + '/' + (date_for_check.getDate() - 1) + '.csv',
		allValidOptions: '-q \'{ "day": ' + '"' + (date_for_check.getDate() - 1) + '"' + ' }\''
		//allValidOptions: '-q \'{ "day": "19" }\''
	};

	mongotocsv.export(option , function(err , success){
		console.log(err);
		console.log(success);
	});;
});

var coap        = require('coap')
var server      = coap.createServer();

var is_recieved = new Array(3);

var data = {};

server.on('request', function(req, res) {
	console.log("-------------------------");
	console.log("url = " + req.url);
	console.log("length = " + req.payload.toString().length);
	console.log(req.payload.toString());

	if(req.url.split('/')[1] == 'sensor1')
	{
		console.log("is_recieved_1 = " + is_recieved[0]);
		var count = Number(req.payload.toString().substring(0,5));
		console.log("count = " + count);
		var airtemp = Number(req.payload.toString().substring(5,10));
		console.log("airtemp = " + airtemp);
		var humidity = Number(req.payload.toString().substring(10,15));
		console.log("humidity = " + humidity);
		//post_action(req , res);
		is_recieved[0] = 1;

		data['count'] = count;
		data['temp'] = airtemp;
		data['humidity'] = humidity;
	}
	else if(req.url.split('/')[1] == 'sensor2')
	{
		console.log("is_recieved_2 = " + is_recieved[1]);
		var cds = Number(req.payload.toString().substring(0,5));
		console.log("cds = " + cds);
		var vin_solar = Number(req.payload.toString().substring(5,10));
		console.log("vin_solar = " + vin_solar);
		var vin_bat = Number(req.payload.toString().substring(10,15));
		console.log("vin_bat = " + vin_bat);
		//post_action(req , res);
		is_recieved[1] = 1;

		data['cds'] = cds;
		data['vol_solar'] = vin_solar;
		data['vol_bat'] = vin_bat;
	}
	else if(req.url.split('/')[1] == 'sensor3')
	{
		console.log("is_recieved_3 = " + is_recieved[2]);
		var amps_solar = Number(req.payload.toString().substring(0,5));
		console.log("amps_solar = " + amps_solar);
		var amps_vat = Number(req.payload.toString().substring(5,10));
		console.log("amps_vat = " + amps_vat);
		is_recieved[2] = 1;

		data['Amp_solar'] = amps_solar;
		data['Amp_bat'] = amps_vat;
	}
	else{
			console.log("wrong url type");
	}

	if(is_recieved[0] == 1 && is_recieved[1] == 1 && is_recieved[2] == 1)
	{
		console.log("post action called!");

		is_recieved[0] = 0;
		is_recieved[1] = 0;
		is_recieved[2] = 0;

		var dt = new Date();
		var day = dt.getDate();
		dt = dt.getFullYear() + "/" + (dt.getMonth() + 1) + "/" + dt.getDate() +
			" " + dt.getHours() + ":" + dt.getMinutes() + ":" + (10*Math.floor(dt.getSeconds()/10));

		console.log("post action called222222222222!");

		data['created_at'] = dt;
		data['day'] = String(day);
		console.log(data);

		post_action(data);
	}
})

// the default CoAP port is 5683
server.listen(function() {
  console.log("listen!!");
})

function post_action(data){
	console.log('In post_Action');

	var insert_data = {};
	insert_data['created_at'] = data['created_at'];
	insert_data['count'] = data['count'];
	insert_data['temp'] = data['temp'];
	insert_data['humidity'] = data['humidity'];
	insert_data['cds'] = data['cds'];
	insert_data['Amp_solar'] = data['Amp_solar'];
	insert_data['Amp_bat'] = data['Amp_bat'];
	insert_data['day'] = data['day'];
	insert_data['vol_solar'] = data['vol_solar']
	insert_data['vol_bat'] = data['vol_bat']	
	

	MongoClient.connect(connectionUrl, function(err, client) {
		console.log("Connected correctly to server");
		// Get some collection
		if (err)	console.log(err);

		const db = client.db(dbName);

		var collection = db.collection(sampleCollection);

		collection.insert(insert_data , function(error,result){
		//here result will contain an array of records inserted
		//collection.save(insert_data , function(error,result){
			if(!error) {
				console.log("Success");
				console.log(result);
			} else {
				console.log("Some error was encountered");
			}
			client.close();
		});
		console.log("end");
	});
}
