package rabbitmq.impl.nodejs;

import rabbitmq.externs.nodejs.Message as NativeMessage;

class Message extends MessageBase {
    private var nativeMessage:NativeMessage = null;

    private override function get_headers():Map<String, Any> {
        if (nativeMessage == null) {
            return super.get_headers();
        }

        var props = this.properties;
        if (props == null || !props.exists("headers")) {
            return null;
        }

        if (_headers != null) {
            return _headers;
        }

        var h:Dynamic = props.get("headers");
        for (f in Reflect.fields(h)) {
            var v = Reflect.field(h, f);
            if (_headers == null) {
                _headers = [];
            }
            _headers.set(f, v);
        }

        return _headers;


        return null;
    }

    private var _properties:Map<String, Any> = null;
    private override function get_properties():Map<String, Any> {
        if (nativeMessage == null) {
            return super.get_properties();
        }

        if (nativeMessage.properties == null) {
            return null;
        }

        if (_properties != null) {
            return _properties;
        }

        var p:Dynamic = nativeMessage.properties;
        for (f in Reflect.fields(p)) {
            var v = Reflect.field(p, f);
            if (_properties == null) {
                _properties = [];
            }
            _properties.set(f, v);
        }

        return _properties;
    }
}