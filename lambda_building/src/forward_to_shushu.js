'use strict';
console.log('Loading function');

// Depend npm modules
const log = require('lambda-log');
// Depend system modules
const AWS = require('aws-sdk');

exports.handler = function(event, context) {
    //console.log(JSON.stringify(event, null, 2));
    event.Records.forEach(function(record) {
        // Kinesis data is base64 encoded so decode here
        var payload = Buffer.from(record.kinesis.data, 'base64').toString('ascii');
        console.log('Decoded payload:', payload);
        log.info('from lambda-log: ', payload);
    });
};
