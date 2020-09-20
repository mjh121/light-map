package com.ssu.isb;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class CoordDataReader {
	
	public static List<String[]> getCoordDataInDB(ArrayList<Double> coord) {
		List<String[]> coordDataList = new ArrayList<String[]>();
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		
		try {
			Class.forName("com.mysql.cj.jdbc.Driver");
			// please change variables: url,, user__id, user_pw
			String url = "jdbc:mysql://url/isb?useUnicode=true&characterEncoding=utf8";
			String user_id = "id";
			String user_pw = "pw";
			conn = DriverManager.getConnection(url, user_id, user_pw);
			
			stmt = conn.createStatement();
			String sql = "SELECT latitude, longitude, "
					+ "(6371*acos(cos(radians("+coord.get(1)+"))*cos(radians(latitude))*cos(radians(longitude)-radians("+coord.get(0)+"))+sin(radians("+coord.get(1)+"))*sin(radians(latitude))))"
					+ "AS distance FROM light_info HAVING distance <= 0.5 ORDER BY distance  LIMIT 0,300";
	
			rs = stmt.executeQuery(sql);
			while(rs.next()) {
				String longitude = rs.getString("longitude");
				String latitude = rs.getString("latitude");
				if(longitude == null && latitude == null) {}
				else {
					String[] coordArrStr = {longitude.toString(), latitude.toString()};	
					coordDataList.add(coordArrStr);
				}
			}
			
			conn.close();
			stmt.close();
			rs.close();
		} catch( ClassNotFoundException e){
            System.out.println("드라이버 로딩 실패");
        }
        catch( SQLException e){
            System.out.println("에러 " + e);
        }

		return coordDataList;
	}
}
