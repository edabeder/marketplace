import 'package:postgres/postgres.dart';

class PostgresDBConnector {
  static final PostgresDBConnector _instance = PostgresDBConnector._internal();
  late PostgreSQLConnection _connection;

  factory PostgresDBConnector() => _instance;

  PostgresDBConnector._internal() {
    _connect();
  }

  Future<void> _connect() async {
    _connection = PostgreSQLConnection('10.0.2.2', 5432, 'GeekchainDB', username: 'postgres', password: '12345');
    await _connection.open();
  }

  Future<PostgreSQLConnection> get connection async {
    if (_connection == null || _connection.isClosed) {
      await _connect();
    }

    return _connection;
  }

  Future<void> closeConnection() async {
    if (_connection != null && !_connection.isClosed) {
      await _connection.close();
    }
  }
}
