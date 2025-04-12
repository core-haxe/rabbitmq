package rabbitmq;

import promises.PromiseUtils;
import promises.Promise;

class ConnectionManager {
    public static var autoReconnect:Bool = true;
    public static var autoReconnectIntervalMS:Int = 1000;

    private static var _instance:ConnectionManager = null;
    public static var instance(get, null):ConnectionManager;
    private static function get_instance():ConnectionManager {
        if (_instance != null) {
            return _instance;
        }

        _instance = new ConnectionManager();
        return _instance;
    }

    private var _connections:Map<String, Connection> = [];
    private function new() {

    }

    public function closeAll():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            var promises = [];
            for (connection in _connections) {
                promises.push(connection.close.bind());
            }
    
            PromiseUtils.runSequentially(promises).then(_ -> {
                resolve(true);
            }, error -> {
                reject(error);
            });
        });
    }

    public function getConnection(url:String, force:Bool = false):Promise<Connection> {
        if (force) { // we can force a new connection, this is useful for reconnection (the connection listeners will clean up anyway, but this way we dont need to rely on any order)
            var connection = _connections.get(url);
            _connections.remove(url);
            if (connection != null) {
                connection.unlistenFor("close", onConnectionClosed);
                connection.unlistenFor("error", onConnectionErrored);
            }
        }
        return new Promise((resolve, reject) -> {
            var connection = _connections.get(url);
            if (connection != null) {
                resolve(connection);
                return;
            }

            var connection = new Connection(url);
            connection.listenFor("close", onConnectionClosed);
            connection.listenFor("error", onConnectionErrored);
            connection.connect().then(result -> {
                _connections.set(url, connection);
                resolve(connection);
            }, (error:RabbitMQError) -> {
                reject(error);
            });
        });
    }

    private function onConnectionClosed(_, connection:Connection) {
        trace(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> onConnectionClosed");
        connection.unlistenFor("close", onConnectionClosed);
        connection.unlistenFor("error", onConnectionErrored);
        _connections.remove(connection.url);
    }

    private function onConnectionErrored(error:Any, connection:Connection) {
        trace(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> onConnectionErrored", error);
    }
}