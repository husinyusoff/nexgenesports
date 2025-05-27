package All;
//
//import java.sql.*;
//import java.util.*;
//
//public class TournamentDAO {
//  public static List<Tournament> listAll() throws SQLException {
//    String sql = "SELECT * FROM program_tournament ORDER BY startDate";
//    try (Connection c = DBConnection.getConnection();
//         PreparedStatement ps = c.prepareStatement(sql);
//         ResultSet rs = ps.executeQuery()) {
//      List<Tournament> list = new ArrayList<>();
//      while (rs.next()) {
//        Tournament t = new Tournament(
//          rs.getString("progID"),
//          rs.getString("gameID"),
//          rs.getString("programName"),
//          rs.getFloat("progFee"),
//          rs.getString("meritLevel"),
//          rs.getString("place"),
//          rs.getString("description"),
//          rs.getDate("startDate").toLocalDate(),
//          rs.getDate("endDate") == null ? null : rs.getDate("endDate").toLocalDate(),
//          rs.getTime("startTime").toLocalTime(),
//          rs.getTime("endTime") == null ? null : rs.getTime("endTime").toLocalTime(),
//          rs.getFloat("prizePool")
//        );
//        list.add(t);
//      }
//      return list;
//    }
//  }
//}
