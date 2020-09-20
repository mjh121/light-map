package com.ssu.isb;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URI;
import java.net.URISyntaxException;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

public class WebGetConnection {
	private HttpClient httpClient;
	private HttpGet httpGet;
	
	private String url = "";
	
	public WebGetConnection(String url) {
		this.url = url;
		init();
	}
	
	private void init() {
		httpClient = HttpClients.createDefault();
		httpGet = new HttpGet(url);
	}
	
	public void setURL(String url) {
		try {
			httpGet.setURI(new URI(url));
		} catch (URISyntaxException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public String requestToURL() {
		String resStr = "";
		
		try {
			HttpResponse response = httpClient.execute(httpGet); 
			HttpEntity respEntity = response.getEntity();
			
			if(respEntity != null) {
				resStr = EntityUtils.toString(respEntity); 
			}
			
		}  catch (UnsupportedEncodingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (ClientProtocolException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} 
		return resStr;
	}
}