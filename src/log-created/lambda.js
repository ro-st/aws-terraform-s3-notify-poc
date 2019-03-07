const AWS = require('aws-sdk');
AWS.config.update({ region: process.env.AWS_DEPLOY_REGION || 'eu-west-1' });


async function main(event, context) {

    console.log('got event data:', event);
    console.log('got context data:', event);

    try {
        const sns = new AWS.SNS();

        const { eventTime, eventName, s3 } = event.Records[0];
        const Message = `Hi! At ${eventTime} someone used ${eventName} in bucket ${s3.bucket.name} on key ${s3.object.key}`;

        await sns.publish({
            PhoneNumber: process.env.AWS_ADMIN_PHONE_NUMBER,
            Subject: 'idwiw',
            Message,
        }).promise();

        return {
            statusCode: 200,
        };

    } catch (err) {
        if (err.code) {
            return {
                statusCode: 500,
                message: err.code,
            }
        } else {
            return {
                statusCode: 500,
                message: "woops",
                err,
            }
        }
    }

};

if (require.main === module) {

    (main)({ type: 'event', }, { type: 'context', });

} else {
    module.exports.handler = main;
}