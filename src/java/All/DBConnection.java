// src/All/DBConnection.java
package All;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String URL = "jdbc:mysql://localhost:3306/NexGenEsports?useSSL=false&serverTimezone=UTC";
    private static final String USER = "root";
    private static final String PASSWORD = "";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("[DBConnection] JDBC driver loaded.");
        } catch (ClassNotFoundException e) {
            System.out.println("[DBConnection] Driver load FAILED.");
            e.printStackTrace(System.out);
        }
    }

    public static Connection getConnection() throws SQLException {
        System.out.println("[DBConnection] Connecting to " + URL);
        Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
        System.out.println("[DBConnection] Connection established: " + conn);
        return conn;
    }
}
