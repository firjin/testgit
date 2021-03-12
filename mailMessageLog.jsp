<%@ page language="java" contentType="text/html; charset=gbk"%>
<%@page import="com.esafenet.mail.bean.MailMessageLogInfo"%>
<%@page import="com.esafenet.mail.bean.MailMessageLogVO"%>
<%@page import="com.esafenet.mail.model.MailMessageLogModel"%>
<%@include file="/languageApplicationResources.jsp"%>
<%@page
	import="com.common.tools.*,com.common.tools.pageutil.log.*,com.esafenet.util.*,com.common.tools.FormatDate,java.util.*,com.esafenet.dao.log.*,com.esafenet.beans.log.*"%>
<%@page import="com.esafenet.beans.user.OrganiseStructInfo"%>
<%@page import="com.esafenet.model.user.OrganiseStructModel"%>
<%
String path1 = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path1+"/";

%>
<jsp:useBean scope="session" class="com.org.acl.LoginMng" id="loginMng" />
<%
	if (loginMng == null || !loginMng.isLogin()) {
		response.sendRedirect("../loginExpire.jsp");
		return;
	}
	
	request.setCharacterEncoding("GBK");

%>
<%
	int currPage = RequestUtil.getIntParameter(request, "curpage", 1); //当前是第几页
	String subgroupState = RequestUtil.getParameter(request, "subgroupState", "0");
	String mailTheme = RequestUtil.getParameter(request, "mailTheme",""); //邮件主题
	String addresser = RequestUtil.getParameter(request, "addresser","");//发件人查询
	String addressee = RequestUtil.getParameter(request, "addressee","");//收件人查询
	String hostIp = RequestUtil.getParameter(request, "hostIp","");//ip地址
	String hostName = RequestUtil.getParameter(request, "hostName","");//机器名
	String hostMac = RequestUtil.getParameter(request, "hostMac","");//mac地址
	String startDate = request.getParameter("startDate"); //起始时间
	String endDate = request.getParameter("endDate"); //截止时间
	// 部门查询 
	String organiseId = RequestUtil.getParameter(request, "organiseId", "0");//
	
	if (organiseId == null) {
		organiseId = "";
	}
	//时间段
	if (startDate == null) {
		//startDate = "";
		startDate = CDGUtil.getCurrentTime().substring(0, 10);
	} else {
		startDate = request.getParameter("startDate");
	}
	if (endDate == null) {
		//endDate = "";
		endDate = CDGUtil.getCurrentTime().substring(0, 10);
	} else {
		endDate = request.getParameter("endDate");
	}
	//填充查询条件
	MailMessageLogVO mailMessageLogVO = new MailMessageLogVO();
	mailMessageLogVO.setOrganiseId(organiseId);
	mailMessageLogVO.setStartDate(startDate);
	mailMessageLogVO.setEndDate(endDate);
	mailMessageLogVO.setAddresser(addresser);
	mailMessageLogVO.setAddressee(addressee);
	mailMessageLogVO.setMailTheme(mailTheme);
	mailMessageLogVO.setHostName(hostName);
	mailMessageLogVO.setHostIp(hostIp);
	mailMessageLogVO.setHostMac(hostMac);
	mailMessageLogVO.setUserID(loginMng.getUser().getUserId());
	mailMessageLogVO.setSubgroupState(subgroupState);
	List<MailMessageLogInfo> mailMessageLogList = new ArrayList<MailMessageLogInfo>();

	MailMessageLogModel mailMessageLogModel = MailMessageLogModel.getMailMessageLogModel();
	LogPageUtil pageUtil = mailMessageLogModel.getMailMessagePageUtil(mailMessageLogVO, currPage);

	session.setAttribute("maxrowcount", "" + pageUtil.getRecordNum());
	session.setAttribute("maxpage", "" + pageUtil.getPageNum());
	session.setAttribute("curpage", "" + currPage);
	session.setAttribute("startDate", "" + startDate);
	session.setAttribute("endDate", "" + endDate);

	mailMessageLogList = pageUtil.getRecords();

	int count = (mailMessageLogList != null&& mailMessageLogList.size() > 0 ? mailMessageLogList.size() : 0);

//	OrganiseStructModel orgM = new OrganiseStructModel();
//	List<OrganiseStructInfo> orgList = orgM.showFilterUserGroups(loginMng.getUserName(), rp);

	boolean notSmartSec = !CDGUtil.isSmartSec() || CDGUtil.isIntegration();//不是smartSec(动态加解密)版本
%>


<html>
	<head>
		<meta>
		<link rel="stylesheet" type="text/css" href="../css/DataGrid.css">
		<link rel="stylesheet" href="../style/style2/style.css"
			type="text/css">
		<script type="text/javascript" src="../js/verify.js"></script>
		<script type="text/javascript" src="../js/commons.js"></script>
		<script type="text/javascript" src="../js/prototype-1.6.0.2.js"></script>
		<script type="text/javascript" src="../js/My97DatePicker/WdatePicker.js"></script>
		<script type="text/javascript">
		//清空数据
	    function clearValues(){
	    	$("addresser").value = "";
	    	$("addressee").value = "";
	    	$("mailTheme").value = "";
	    	$("hostName").value = "";
	    	$("hostIp").value = "";
	    	$("hostMac").value = "";
	    }
		function check(){
			for(i=0;i<document.forms[0].elements.length;i++){
				var e = document.forms[0].elements[i];
				if(e.name=='logOperation'){
					e.checked = document.getElementById('checkAll').checked;
				}
			}
		}

 function tablehide(tablehide){
	var objtbl = document.getElementById(tablehide);	
	if (objtbl.style.display == "")
		objtbl.style.display = "none";
	else
		objtbl.style.display = "";
    }
    
    //按钮提交
    function searchLogs(){
  	  	var thisForm = document.getElementsByName("myForm")[0];
    	var startDate = thisForm.startDate.value;
    	var endDate = thisForm.endDate.value;
   		var addresser = document.getElementById("addresser").value
		if(!isRightFileName(addresser)){
    	   alert("<%=rp.getString("sjgl.yjsj.yjfjr") %>"+"<%=rp.getString("zzry.bnbhtszf")%>:"+"^&*\\/?\'\":<>|'’;！#￥￥%……&&*——{}：”|》？《");
    	   return;
    	}
   		var addressee = document.getElementById("addressee").value
		if(!isRightFileName(addressee)){
    	   alert("<%=rp.getString("sjgl.yjsj.yjsjr")%>"+"<%=rp.getString("zzry.bnbhtszf")%>:"+"^&*\\/?\'\":<>|'’;！#￥￥%……&&*——{}：”|》？《");
    	   return;
    	}
   		var mailTheme = document.getElementById("mailTheme").value
		if(!isRightFileName(mailTheme)){
    	   alert("<%=rp.getString("sjgl.yjsj.yjxq") %>"+"<%=rp.getString("zzry.bnbhtszf")%>:"+"^&*\\/?\'\":<>|'’;！#￥￥%……&&*——{}：”|》？《");
    	   return;
    	}
   		var hostName = document.getElementById("hostName").value
		if(!isRightFileName(hostName)){
    	   alert("<%=rp.getString("sjgl.yjsj.zdjqm") %>"+"<%=rp.getString("zzry.bnbhtszf")%>:"+"^&*\\/?\'\":<>|'’;！#￥￥%……&&*——{}：”|》？《");
    	   return;
    	}
   		var hostIp = document.getElementById("hostIp").value
		if(!isRightFileName(hostIp)){
    	   alert("<%=rp.getString("sjgl.yjsj.zdjipdz") %>"+"<%=rp.getString("zzry.bnbhtszf")%>:"+"^&*\\/?\'\":<>|'’;！#￥￥%……&&*——{}：”|》？《");
    	   return;
    	}
    	var startArray = startDate.split('-');
        var endArray = endDate.split('-');  
		//判断年份月份必须相等
        if(startArray[0] != endArray[0] || startArray[1]!=endArray[1]){
        	alert("<%=rp.getString("sjgl.yjsj.bzckyczqcxszrq") %>");
        	return false;
        }
    	
    	
    	if(!startDateCompareEndDate(startDate,endDate)) {
    		document.myForm.endDate.focus();
    		return false;
    	}
    	var crpage = document.getElementById("curpage");
		if(crpage !=null && crpage!="undefined"&& crpage!="null"){
			document.getElementById("curpage").value= "1";
		}
    	thisForm.action = "mailMessageLog.jsp;jsessionid=<%=session.getId()%>";
    	thisForm.submit();
    }
    
    function isRightFileName(targetValue){
        var input = "^&*\\/?\'\":<>|'’;！#￥￥%……&&*——{}：”|》？《";
		for(var i = 0; i < targetValue.length ; i++) {
			var char1 = targetValue.charAt(i);
			for(var j = 0; j < input.length; j++) {
			    //alert("char1:"+char1+",input["+j+"]:"+input.charAt(j));
				if(char1 == input.charAt(j)) {
					return false;
				}
			}
		}	
		return true;
 } 
    
    
    //验证机器IP
    function verifyMachineIp() {
    	var value = document.myForm.machineIp.value;
    	if(!verifySimpleIP(value)) {
    		setRow(document.myForm.machineIp);
    		return false;
    	}
    	return true;
    }
    //比较起始时间和结束时间
    function startDateCompareEndDate(startDate,endDate) {
  		var SValue = 0;
    	var EValue = 0;
    	var startArray = startDate.split("-");
    	var endArray = endDate.split("-");
    	if(startDate != "" && endDate != "") {
	    	var startD = new Date(startArray[0],parseInt(startArray[1]-1),startArray[2]);   
	        var endD = new Date(endArray[0],parseInt(endArray[1]-1),endArray[2]);   
	        var currD = new Date();
	        
	        if(startD > currD){
           		alert("<%=rp.getString("zdgl.zdgl.qsrqbndydqrq") %>");
           		document.myForm.startDate.focus();
	        	 return false;
	      	 }
	      	if(endD > currD){
	         	alert("<%=rp.getString("zdgl.zdgl.jzrqbndydqrq") %>");
	         	document.myForm.endDate.focus();
	        	 return false;
	      	}
	      	if(startD > endD){
	        	 alert("<%=rp.getString("zdgl.zdgl.qsrqbndyjzrq") %>");
	        	 document.myForm.startDate.focus();
	  			return false;
	      	}
	      	return true;
    	} else {
    		 alert("<%=rp.getString("sjgl.yjsj.sjbkwk") %>");
    		return false;
    	}  		
    }
    
    function onc(obj){
    	if(obj.checked==false){
    		document.getElementById("checkAll").checked=false;
    	}
    }
    
    function download(fileName,realPath,appUser){
	        fileName=fileName+".eml";
            document.getElementById("realPath").value=realPath;
            document.getElementById("fileName").value=fileName;
            document.getElementById("appUser").value=appUser;
			downloadForm.submit();
		}
    //邮件详情  邮件id  路径
    function mailDatails(mailMessageLogID,FieldText01){
//    	alert(mailMessageLogID);
    	var thisForm = document.getElementById("myForm");
    	thisForm.mailMessageLogID.value=mailMessageLogID;
    	thisForm.FieldText01.value=FieldText01;
		thisForm.action="<%=request.getContextPath()%>/mailMessageLog/ReadEMLServlet";
		
    	thisForm.submit();
    }
	function EnterPress(e){ //传入 event   
		  var e = e || window.event;   
		  if(e.keyCode == 13){   
		  	searchLogs();   
		  }   
	}
</script>
	</head>
	<body class="main_frame">
		<form action="<%=basePath%>/download1" method="post"
			name="downloadForm">
			<input type="hidden" id="realPath" name="realPath" value="">
			<input type="hidden" id="fileName" name="fileName" value="">
		    <input type="hidden" id="appUser" name="appUser" value="" />
			<input type="hidden" name="down" value="true">
		</form>
		<form method="post" action="mailMessageLog.jsp;jsessionid=<%=session.getId()%>" id="myForm" name="myForm">
			<input type="hidden" name="command" value="">
			<input type="hidden" name="mailMessageLogID" value="">  <!-- 邮件ID -->
			<input type="hidden" name="FieldText01" value="">  <!-- 邮件eml存放路径 -->
			<input type="hidden" name="fromurl" value="mailMessageLog.jsp;jsessionid=<%=session.getId()%>">
			<input type="hidden" id="organiseId" name="organiseId" value="<%=organiseId%>">
			<table align="center" class="DataGrid" border="0" cellpadding="1"
				cellspacing="1" width="95%">
				<thead class="DataGridThead">
					<tr>
						<th colspan="10">
							<!-- 表格标题 -->
							<%=rp.getString("zzry.fwq") %>(<%=request.getServerName()%>)<%=rp.getString("sjgl.yjsj.yjrzcx") %>
						</th>
					</tr>
				</thead>
				<tr class="DataGridRow">
					<td align="right">
						<%=rp.getString("log.qsrq") %>：
					</td>
					<td align="left">
						<input type="text" id="startDate" name="startDate"
							style="cursor: hand;" readonly="readonly"
							onfocus="var endDate=$dp.$('endDate');WdatePicker({onpicked:function(){endDate.focus();},maxDate:'#F{$dp.$D(\'endDate\')}',dateFmt:'yyyy-MM-dd',lang:'<%=rp.getlanguage() %>'})"
							value="<%=startDate%>" size="20">
					</td>
					<td align="right">
						<%=rp.getString("log.jzrq") %>：
					</td>
					<td align="left">		
						<input type="text" id="endDate" name="endDate" 
							readonly="readonly"
							onfocus="WdatePicker({minDate:'#F{$dp.$D(\'startDate\')}',maxDate:'%y-%M-%d',dateFmt:'yyyy-MM-dd',lang:'<%=rp.getlanguage() %>'})"
							style="cursor: hand;"
							value="<%=endDate%>" size="20">
					</td>
					<td align="right">
						<%=rp.getString("sjgl.yjsj.yjfjr") %>：
					</td>
					<td align="left">
						<input id="addresser" name="addresser" type="text" size="20" value="<%=null==addresser?"":addresser %>" maxlength="50" onkeyup="EnterPress(event)">
					</td>
				</tr>
				<tr class="DataGridRow">
					<td align="right">
						<%=rp.getString("sjgl.yjsj.yjsjr") %>：
					</td>
					<td align="left">
						<input id="addressee" name="addressee" type="text" size="20" value="<%=null==addressee?"":addressee %>" maxlength="50" onkeyup="EnterPress(event)">
					</td>
					<td align="right">
						<%=rp.getString("sjgl.yjsj.yjxq") %>：
					</td>
					<td align="left">
						<input id="mailTheme" name="mailTheme" type="text" size="20" value="<%=null==mailTheme?"":mailTheme %>" maxlength="50" onkeyup="EnterPress(event)">
					</td>
					<td align="right">
						<%=rp.getString("sjgl.yjsj.zdjqm") %>：
					</td>
					<td align="left">
						<input id="hostName" name="hostName" type="text" size="20" value="<%=null==hostName?"":hostName %>" maxlength="50" onkeyup="EnterPress(event)">
					</td>
				</tr>
				<tr class="DataGridRow">
					<td align="right">
						<%=rp.getString("sjgl.yjsj.zdjipdz") %>：
					</td>
					<td align="left">
						<input id="hostIp" name="hostIp" type="text" size="20" value="<%=null==hostIp?"":hostIp %>" maxlength="50" onkeyup="EnterPress(event)">
					</td>
					<td align="right">
						<%=rp.getString("sjgl.yjsj.zdjmacdz") %>：
					</td>
					<td align="left">
						<input id="hostMac" name="hostMac" type="text" size="20" value="<%=null==hostMac?"":hostMac %>" maxlength="50" onkeyup="EnterPress(event)">
					</td>
					<td align="right">
						<span id="subgroupuser0" style="display: none">
							<%=rp.getString("zzry.zzyh") %>：
						</span>
					</td>
					<td align="left">
						<span id="subgroupuser" style="display: none">
							<select name="subgroupState" id="subgroupState" style="width:130" onkeyup="EnterPress(event)" onblur="checkpolcyselec()">
								<option value="0" <%if(subgroupState.equals("0")){%>
									selected="selected" <%} %>>
									<%=rp.getString("zzry.bbh") %>
								<option value="1" <%if(subgroupState.equals("1")){%>
									selected="selected" <%} %>>
									<%=rp.getString("zzry.bh") %>
							</select>
						</span>
					</td>
				</tr>	

				<tr class="DataGridThead">
					<td align="center" colspan="10">
						<input type="button" name="search" value="<%=rp.getString("global.cx") %>"
							onclick="searchLogs();">
						&nbsp;
						&nbsp;
						<input type="button" name="clear" onclick="clearValues();"
							value="<%=rp.getString("log.qk")%>">
						&nbsp;
					</td>
				</tr>
			</table>
			<br>
			<br>
			<table align="center" class="DataGrid" border="0" cellpadding="1"
				cellspacing="1" width="95%">
				<thead class="DataGridThead">
					<tr>
						<th style="width:5%" align="center">
							<%=rp.getString("bdgl.xh") %>
						</th>
						<th align="center" style="width:12%">
							<strong><%=rp.getString("sjgl.yjsj.yjfjr") %></strong>
						</th>
						<th align="center" style="width:12%">
							<strong><%=rp.getString("sjgl.yjsj.yjsjr") %></strong>
						</th>
						<th align="center" style="width:13%">
							<strong><%=rp.getString("sjgl.yjsj.yjfssj") %></strong>
						</th>
						<th align="center" style="width:23%">
							<strong><%=rp.getString("sjgl.yjsj.yjxq") %></strong>
						</th>
						<th align="center" style="width:12%">
							<strong><%=rp.getString("sjgl.yjsj.zdjqm") %></strong>
						</th>
						<th align="center" style="width:13%">
							<strong><%=rp.getString("sjgl.yjsj.zdjipdz") %></strong>
						</th>
						<th align="center" style="width:20%">
							<strong><%=rp.getString("sjgl.yjsj.zdjmacdz") %></strong>
						</th>
					</tr>
				</thead>
				<%
					if (count > 0) {
						for (int i = 0;mailMessageLogList!=null && i < mailMessageLogList.size(); i++) {
						MailMessageLogInfo mailMessageLogInfo = mailMessageLogList.get(i);
				%>
				<tr class="DataGridRow">
					<td align="center">
						<%=i+1 %>
					</td>
					<td align="center" style="word-wrap:break-word;word-break:break-all"><%=mailMessageLogInfo.getAddresser()%></td>
					<td align="center" style="word-wrap:break-word;word-break:break-all"><%=mailMessageLogInfo.getAddresseeTo()%></td>
					<td align="center" style="word-wrap:break-word;word-break:break-all"><%=mailMessageLogInfo.getCreatTime() %></td>
					<td align="center" style="word-wrap:break-word;word-break:break-all"><a href="javascript:download('<%=mailMessageLogInfo.getMailMessageLogID() %>','<%=mailMessageLogInfo.getMailMessageLogID() %>,'<%=mailMessageLogInfo.getUserId() %>');"><%=mailMessageLogInfo.getMailTheme() == null || mailMessageLogInfo.getMailTheme().equals("") ? "无标题" : mailMessageLogInfo.getMailTheme()%></a></td>
					<td align="center" style="word-wrap:break-word;word-break:break-all"><%=mailMessageLogInfo.getHostName()%></td>
					<td align="center" style="word-wrap:break-word;word-break:break-all"><%=mailMessageLogInfo.getHostIp()%></td>
					<td align="center" style="word-wrap:break-word;word-break:break-all"><%=mailMessageLogInfo.getHostMac()%></td>
				</tr>
				<%
					}
				%>
				<tr class="DataGridRow">
					<td colspan="14" align="right">
						&nbsp;
						<%@include file="../common/page.jsp"%>
					</td>
				</tr>
				<%
					} else {
				%>
				<tr class="DataGridRow">
					<td align="center" colspan="12">
						<%=rp.getString("log.mynycxdjl")%><%--没有您要查询的记录--%>
					</td>
				</tr>
				<%
					}
				%>
				<tr class="DataGridThead">
					<td colspan="10" align="center">
					</td>
				</tr>
			</table>
		</form>
<script type="text/javascript">
if("0"==='<%=organiseId%>'){
	document.getElementById("subgroupuser").style.display = "none";
	document.getElementById("subgroupuser0").style.display = "none";
}else{
	document.getElementById("subgroupuser").style.display = "";
	document.getElementById("subgroupuser0").style.display = "";
}
</script>
	</body>
</html>