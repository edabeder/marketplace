import 'package:postgres/postgres.dart';

class PostgresDBConnector {
  static final PostgresDBConnector _instance = PostgresDBConnector._internal();
  late PostgreSQLConnection _connection;

  factory PostgresDBConnector() => _instance;

  PostgresDBConnector._internal();

  Future<PostgreSQLConnection> get connection async {
    if (_connection != null && !_connection.isClosed) {
      return _connection;
    }

    _connection = PostgreSQLConnection('10.0.2.2', 5432, 'GeekchainDB', username: 'postgres', password: '1234');

    await _connection.open();

    return _connection;
  }

  Future<void> closeConnection() async {
    if (_connection != null && !_connection.isClosed) {
      await _connection.close();
    }
  }
}
/** final conn = await PostgresDBConnector().connection;
final result = await conn.query('SELECT * FROM my_table');
print(result);
 */