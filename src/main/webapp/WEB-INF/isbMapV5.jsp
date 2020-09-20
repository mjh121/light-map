<%@ page language="java" contentType="text/html; charset=UTF-8"
  pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<title>KMLLayer</title>
<!-- API key를 포함하여 브이월드 API URL을 지정하여 호출끝  -->
<script type="text/javascript" src="http://map.vworld.kr/js/vworldMapInit.js.do?version=2.0&apiKey=83DC9A0B-61F9-3EDA-884E-918B2A89BC5D&domain=http://www.kpc.or.kr"></script>

</head>

<body>
  <div id="vmap" style="width:100%;height:700px;left:0px;top:0px"></div>
  <form id='frm' name='frm'>
    <input type="hidden" name="coorddata", id = "coorddata">

  </form>
  <script type="text/javascript">
    var markerLayer;
    var nearCoordData;
    var map2d;
    var globalSelectMarker; // use of check in console
    var responseAddrInfo;
    var globalSelectMarker_x;
    var globalSelectMarker_y;
    var currCenter = [0, 0];
    var rectRadius = 1300;
    var movingThreshold = 0.01;
    var countThreshold = 1500;
    // var hyperParam = [3, 5];
    var hyperParam = [1, 1];
    var light_type_list = ['','가로등', '보안등'];
    var marker_type_list = ['', 'marker', 'marker_blue'];

    // initialize vmap configuration
    vw.MapControllerOption = {
      container : "vmap",
      mapMode : "2d-map",
      basemapType : vw.ol3.BasemapType.GRAPHIC,
      controlDensity : vw.ol3.DensityType.EMPTY,
      interactionDensity : vw.ol3.DensityType.BASIC,
      controlsAutoArrange : true,
      homePosition : vw.ol3.CameraPosition,
      initPosition : vw.ol3.CameraPosition
    };
    mapController = new vw.MapController(vw.MapControllerOption);

    map2d = mapController.Map2D;
    map2d.on('pointermove', function(evt) {
      var feature = map2d.forEachFeatureAtPixel(evt.pixel, function(feature,layer) {
      // if (layer != null && layer.className == 'vw.ol3.layer.Marker') {
      //   $('#param').val('');
      //   $('#param').val(feature.get('id'));

      //   selectMarker = feature;
      //   if(globalSelectMarker == null) {
      //       globalSelectMarker = feature;
      //       // console.log(selectMarker);
      //   } else {
      //     if(globalSelectMarker.ol_uid != selectMarker.ol_uid) {
      //       globalSelectMarker = feature;
      //       // console.log(globalSelectMarker.ol_uid);
      //     }
      //   }
      // } else {
      //  return false;
      // }
      });
    });

    // click event
    map2d.on("singleclick", function(evt) {
      var feature = map2d.forEachFeatureAtPixel(evt.pixel, function(feature,layer) {
      if (layer != null && layer.className == 'vw.ol3.layer.Marker') {
        $('#param').val('');
        $('#param').val(feature.get('id'));

        selectMarker = feature;
        if(globalSelectMarker == null) {
            globalSelectMarker = feature;
        } else {
          // if(globalSelectMarker.ol_uid != selectMarker.ol_uid) {
          //   globalSelectMarker = feature;
          //   console.log(globalSelectMarker.ol_uid);
          globalSelectMarker = feature;
          // }
        }
        feature_x = ol.proj.transform(feature.getGeometry().getFlatCoordinates(),"EPSG:3857", "EPSG:4326")[0];
        feature_y = ol.proj.transform(feature.getGeometry().getFlatCoordinates(),"EPSG:3857", "EPSG:4326")[1];

        $.ajax({
          url: "http://api.vworld.kr/req/address?service=address&request=getAddress&version=2.0&crs=epsg:4326&point="+feature_x+","+feature_y+"&format=xml&type=road&zipcode=true&simple=false&key=83DC9A0B-61F9-3EDA-884E-918B2A89BC5D",
          type: "GET",
          data: "",
          dataType: "xml",
          success: function(result){
            responseAddrInfo = result;
            // console.log("[Addr] get addr info");
            addrStatus = responseAddrInfo.documentElement.getElementsByTagName("status").item(0).textContent;
            if(addrStatus == "OK") {
              // feature.set("contents", responseAddrInfo.documentElement.getElementsByTagName("result").item(0).getElementsByTagName("item").item(0).getElementsByTagName("text").item(0).textContent);
              replaceContents = responseAddrInfo.documentElement.getElementsByTagName("result").item(0).getElementsByTagName("item").item(0).getElementsByTagName("text").item(0).textContent;
            } else {
              // feature.set("contents", "load");
              replaceContents = "load";
            }
          }
        });

        // feature.set("title", "test");
        feature.set("contents", replaceContents);
      } else {
       return false;
      }
      });
    }
      , map2d);

    map2d.getView().setZoom(9);

    // set tool buttons

    var options = {
        map: map2d
      , site : vw.ol3.SiteAlignType.TOP_LEFT   //"top-left"
      , vertical : true
      , collapsed : false
      , collapsible : false
    };    

    var _toolBtnList = [
           new vw.ol3.button.Init(map2d),
           new vw.ol3.button.ZoomIn(map2d),
           new vw.ol3.button.ZoomOut(map2d),
           new vw.ol3.button.DragZoomIn(map2d),
           new vw.ol3.button.DragZoomOut(map2d) ,
           new vw.ol3.button.Pan(map2d),    
           new vw.ol3.button.Prev(map2d),
           new vw.ol3.button.Next(map2d),
           new vw.ol3.button.Full(map2d),
           new vw.ol3.button.Distance(map2d),
           new vw.ol3.button.Area(map2d)  
          ];

    var toolBar = new vw.ol3.control.Toolbar(options);
    toolBar.addToolButtons(_toolBtnList);
    map2d.addControl(toolBar);

    // add farm map layer
    var farm_layer = map2d.addNamedLayer('농업진흥지역도','lt_c_agrixue101');
    map2d.addLayer(farm_layer);
    farm_layer.setVisible(true);

    // add MarkerLayer
    addMarkerLayer();

    // it register map point moving event
    map2d.on("moveend", jsMapGeoLocation);

    function jsMapGeoLocation(pSender, pPixel, pCoord, pWheel, pCtrlKey, pShiftKey, pAltKey, pHandled){
      var center = ol.proj.transform(map2d.getView().getCenter(), "EPSG:3857", "EPSG:4326");
      var center3857 = map2d.getView().getCenter();
      var rectPointTop = [];
      var rectPointBottom = [];

      rectPointTop[0] = center3857[0] - rectRadius;
      rectPointTop[1] = center3857[1] - rectRadius;
      rectPointBottom[0] = center3857[0] + rectRadius;
      rectPointBottom[1] = center3857[1] + rectRadius;

      var zoom = map2d.getView().getZoom();

      // console.log("distance: "+(Math.abs(currCenter[0]-center[0])+Math.abs(currCenter[1]-center[1])));
      if((Math.abs(currCenter[0]-center[0])+Math.abs(currCenter[1]-center[1])) > movingThreshold) {
        currCenter[0] = center[0];
        currCenter[1] = center[1];

        removeAllMarker();

        // get Nearby 'street-light' coordinate and add markers
        $.ajax({
          url: "http://www.safemap.go.kr/sm/commonpoi.do?apikey=AGTO30NX-ERMO-FWDX-604X-G0QGERVJZH&SERVICE=WFS&VERSION=1.0.0&REQUEST=GetFeature&TYPENAME=A2SM_CMMNPOI_STREETLAMP&OUTPUTFORMAT=application/json&BBOX="+rectPointTop[0]+","+rectPointTop[1]+","+rectPointBottom[0]+","+rectPointBottom[1]+"&SRSNAME=EPSG:4326",
          type: "GET",
          data: "",
          dataType: "json",
          success: function(result){
            gcoord = result;
            coordList = result;
            
            addMarker_light(coordList, light_type_list[1], marker_type_list[1]);
            console.log("[street] added marker");
          }
        });

        // get Nearby 'secure-light' coordinate and add markers
        $.ajax({
          url: "http://www.safemap.go.kr/sm/commonpoi.do?apikey=AGTO30NX-ERMO-FWDX-604X-G0QGERVJZH&SERVICE=WFS&VERSION=1.0.0&REQUEST=GetFeature&TYPENAME=A2SM_CMMNPOI_SECULIGHT&OUTPUTFORMAT=application/json&BBOX="+rectPointTop[0]+","+rectPointTop[1]+","+rectPointBottom[0]+","+rectPointBottom[1]+"&SRSNAME=EPSG:4326",
          type: "GET",
          data: "",
          dataType: "json",
          success: function(result){
            gcoord = result;
            coordList = result;
            addMarker_light(coordList, light_type_list[2], marker_type_list[2]);
            console.log("[secure] added marker");
          }
        });     
      }
    }

    function removeMarker() {
      if(isSelectMarker()){
        var features = this.markerLayer.getSource().getFeatures();
        for(var i=0; i<features.length; i++){
          if($('#param').val() == features[i].get('id')){
            this.markerLayer.removeMarker(selectMarker);
            $('#param').val('');
            selectMarker = null;
          }
        }
      }
    }

    function removeAllMarker() {
      if(markerLayer == null){
      } else {
        this.markerLayer.removeAllMarker();
        console.log("removed All Markers");
      }
    }

    function addMarkerLayer() {
        markerLayer = new vw.ol3.layer.Marker(map2d);
        map2d.addLayer(markerLayer);
    }

    function addMarker_light(coordList, light_type, marker_type) {
      var step;
      if(countThreshold > coordList.totalFeatures) {
        step = hyperParam[0];
      } else {
        step = hyperParam[1];
      }
      console
      for (i=0; i<coordList.totalFeatures; i=i+step){
           vw.ol3.markerOption = {
            x : coordList["features"][i]["geometry"]["coordinates"][0],
            y : coordList["features"][i]["geometry"]["coordinates"][1],
            epsg : "EPSG:4326",
            title : light_type,
            contents : light_type,
            iconUrl : 'http://map.vworld.kr/images/ol3/'+marker_type+'.png', 
          text : {
            // offsetX: 0.5, //위치설정
            // offsetY: 20,   //위치설정
            font: '12px Calibri,sans-serif',
            fill: {color: '#000'},
            stroke: {color: '#fff', width: 2},
            text: ''
          },
          attr: {"id":"test","name":"test"}
           };
           markerLayer.addMarker(vw.ol3.markerOption);
      }
    }
// marker click function override
    this.markerClickPopupFunction=function(evt) {
        // var feature;
        console.log("changed marker click function ==");
        // if(vw.ol3.CommonFunc._isMobile()) {
        // feature=featuresAtPixel(evt.pixel);
        // }
        // else {
        //     feature=_vmap.forEachFeatureAtPixel(evt.pixel, function(feature, layer) {
        //         if(layer!=null&&layer.className=='vw.ol3.layer.Marker') {
        //             return feature;
        //         }
        //         else {
        //             return false;
        //         }
        //     });
        // }
        
        // if(feature) {
        //     var featureId=feature.get("id").replace("Marker-", "");
        //     var isCreated=false;
        //     for(var i in vw._vmap.getOverlays().getArray()) {
        //         if(vw._vmap.getOverlays().getArray()[i].get('id').indexOf("MarkerPop-")!=-1) {
        //             if(vw._vmap.getOverlays().getArray()[i].get('id').replace("MarkerPop-", "")==featureId) {
        //                 if(vw._vmap.getOverlays().getArray()[i].rendered_.visible) {
        //                     vw._vmap.getOverlays().getArray()[i].close();
        //                     isCreated=true;
        //                     return;
        //                 }
        //             }   
        //             else {
        //                 if(vw._vmap.getOverlays().getArray()[i].rendered_.visible) {
        //                     vw._vmap.getOverlays().getArray()[i].close();
        //                 }

        //                 var popup=new vw.ol3.popup.Popup();
        //                     popup.setOffset([0, -25]);
        //                     popup.title="<b>"+feature.get('title')+"</b><hr>";
        //                     popup.content=feature.get('contents');
        //                     popup.set("id", "MarkerPop-"+featureId);
        //                     vw._vmap.addOverlay(popup);
        //                     popup.show(popup.content, feature.getGeometry().getCoordinates());
        //                     return;
        //             }
        //         }
        //     }
        //     if(!isCreated) {
        //         var popup=new vw.ol3.popup.Popup();
        //         popup.setOffset([0, -25]);
        //         popup.title="<b>"+feature.get('title')+"</b><hr>";
        //         popup.content=feature.get('contents');
        //         popup.set("id", "MarkerPop-"+featureId);
        //         vw._vmap.addOverlay(popup);
        //         popup.show(popup.content, feature.getGeometry().getCoordinates());
        //         return;
        //     }
        // }
    };

    markerLayer.markerClickPopupFunction = this.markerClickPopupFunction;

// marker popup show function
  vw.ol3.layer.Marker.prototype.showPop=function(feature) {   
    console.log("changed: showpop function ===");
    //   if(feature) {
    //       var featureId=feature.get("id").replace("Marker-", "");
    //       var isCreated=false;
    //       for(var i in vw._vmap.getOverlays().getArray()) {
    //           if(vw._vmap.getOverlays().getArray()[i].get('id').indexOf("MarkerPop-")!=-1) {
    //               if(vw._vmap.getOverlays().getArray()[i].get('id').replace("MarkerPop-", "")==featureId) {
    //                   if(vw._vmap.getOverlays().getArray()[i].rendered_.visible) {
    //                       isCreated=true;
    //                       return;
    //                   }
    //               }
    //               else {
    //                   if(vw._vmap.getOverlays().getArray()[i].rendered_.visible) {
    //                   vw._vmap.getOverlays().getArray()[i].close();
    //               }

    //               var popup=new vw.ol3.popup.Popup();
    //                   popup.setOffset([0, -25]);
    //                   popup.title="<b>"+feature.get('title')+"</b><hr>";
    //                   popup.content=feature.get('contents');
    //                   popup.set("id", "MarkerPop-"+featureId);
    //                   vw._vmap.addOverlay(popup);
    //                   popup.show(popup.content, feature.getGeometry().getCoordinates());
    //                   return;
    //               }
    //           }
    //       }

    //       if(!isCreated) {
    //           var popup=new vw.ol3.popup.Popup();
    //           popup.setOffset([0, -25]);
    //           popup.title="<b>"+feature.get('title')+"</b><hr>";
    //           popup.content=feature.get('contents');
    //           popup.set("id", "MarkerPop-"+featureId);
    //           vw._vmap.addOverlay(popup);
    //           popup.show(popup.content, feature.getGeometry().getCoordinates());
    //           return;
    //       }
    //   }
  }

  </script>
</body>
</html>