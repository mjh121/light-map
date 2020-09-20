package com.ssu.isb;

import java.util.ArrayList;
import java.util.List;

import org.json.simple.JSONObject;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class MapController {
	
	private String API_KEY = "AGTO30NX-ERMO-FWDX-604X-G0QGERVJZH";
	
	@CrossOrigin(origins = "*")
	@RequestMapping(value = "/isb/coorddata.do", method = RequestMethod.POST)
	@ResponseBody
	public List<String[]> getNearCoordData(String coorddata) {
		String[] coordArray = coorddata.split(",");
		
		ArrayList<Double> coordList = new ArrayList<Double>();
		coordList.add(Double.valueOf(coordArray[0]));
		coordList.add(Double.valueOf(coordArray[1]));
		List<String[]> coordDataList = CoordDataReader.getCoordDataInDB(coordList);
		System.out.println("--------get near coordinate data-------");
		
		for(String[] item : coordDataList) {
			System.out.println(item[0]+", "+item[1]);
		}
		return coordDataList;
	}
	
	@CrossOrigin(origins = "*")
	@RequestMapping(value = "/isb/address/req.do", method = RequestMethod.GET)
	@ResponseBody
	public String getAddr(String point) {
		String url = "http://api.vworld.kr/req/address?service=address&request=getAddress&version=2.0&crs=epsg:4326"
				+ "&format=xml&type=road&zipcode=true&simple=false&key=83DC9A0B-61F9-3EDA-884E-918B2A89BC5D&point="+point+"";
		
		WebGetConnection connection = new WebGetConnection(url);
		
		String resStr = connection.requestToURL();
		System.out.println("address : "+ resStr);
		return resStr;
	}	
	
	@CrossOrigin(origins = "*")
	@RequestMapping(value = "/isb/coord/street/req.do", method = RequestMethod.GET)
	@ResponseBody
	public String getStreetCoord(String BBOX) {
		String url = "http://www.safemap.go.kr/sm/commonpoi.do?apikey="+API_KEY+"&SERVICE=WFS&VERSION=1.0.0&REQUEST=GetFeature&TYPENAME=A2SM_CMMNPOI_STREETLAMP&"+
				"OUTPUTFORMAT=application/json&&SRSNAME=EPSG:4326&BBOX="+BBOX+"";
		WebGetConnection connection = new WebGetConnection(url);
		String resStr = connection.requestToURL();
		
		return resStr;
	}		
	
	@CrossOrigin(origins = "*")
	@RequestMapping(value = "/isb/coord/secure/req.do", method = RequestMethod.GET)
	@ResponseBody
	public String getSecureCoord(String BBOX) {
		String url = "http://www.safemap.go.kr/sm/commonpoi.do?apikey="+API_KEY+"&SERVICE=WFS&VERSION=1.0.0&REQUEST=GetFeature&TYPENAME=A2SM_CMMNPOI_SECULIGHT&"+
			"OUTPUTFORMAT=application/json&&SRSNAME=EPSG:4326&BBOX="+BBOX+"";
		WebGetConnection connection = new WebGetConnection(url);
		String resStr = connection.requestToURL();
		
		return resStr;
	}		
}
