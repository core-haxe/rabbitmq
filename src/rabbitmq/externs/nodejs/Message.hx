package rabbitmq.externs.nodejs;

extern typedef Message = {
    var content:BytesBuffer;
    var fields:Dynamic;
    var properties:Dynamic;
}