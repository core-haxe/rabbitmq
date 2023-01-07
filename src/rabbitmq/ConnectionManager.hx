package rabbitmq;

import promises.Promise;

class ConnectionManager {
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

    public function getConnection(url:String):Promise<Connection> {
        return new Promise((resolve, reject) -> {
            var connection = _connections.get(url);
            if (connection != null) {
                resolve(connection);
                return;
            }

            var connection = new Connection(url);
            connection.connect().then(result -> {
                _connections.set(url, connection);
                resolve(connection);
            }, (error:RabbitMQError) -> {
                reject(error);
            });
        });
    }
}