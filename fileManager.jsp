<%@ page language="java" contentType="text/html; charset=gbk"%>
<%@page import="com.esafenet.dao.user.UserDao"%>
<%@page import="jEnable.util.JEConfig"%>
<%@page import="com.esafenet.JSPService.UserManagerService"%>
<%@page import="com.esafenet.model.policy.PolicyModel"%>
<%@page import="com.esafenet.audit.bean.EmailAudit"%>
<%@page import="com.esafenet.audit.dao.EmailAuditDao"%>
<%@page import="com.esafenet.audit.dao.PrintAuditDao"%>
<%@page import="com.esafenet.audit.bean.PrintAudit"%>
<%@page import="com.esafenet.audit.bean.FileAudit"%>
<%@page import="com.esafenet.audit.dao.FileAuditDao"%>
<%@include file="../languageApplicationResources.jsp"%>
<%@page import="com.common.tools.*,com.common.tools.pageutil.*,com.esafenet.util.*,java.util.*"%>
<%@page import="com.org.User"%>
<%@page import="com.esafenet.dao.user.OrganiseStructDao"%>
<%@page import="com.esafenet.dao.policy.PolicyDao"%>
<%@page import="com.esafenet.beans.policy.PolicyInfo"%>
<%@page import="com.esafenet.dao.system.LicenseDao"%>
<%@page import="com.esafenet.model.user.UserModel"%>
<jsp:useBean scope="session" class="com.org.acl.LoginMng" id="loginMng" />
<%
	String path1 = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path1+"/";
%>
<%
	if (loginMng == null || !loginMng.isLogin()) {
		response.sendRedirect("../loginExpire.jsp");
		return;
	}
	String startDate = request.getParameter("statrD"); //起始时间
	String endDate = request.getParameter("endD"); //截止时间
	//时间段
	if (startDate == null) {
		//startDate = "";
		startDate = CDGUtil.getCurrentTime().substring(0, 10);
	} else {
		startDate = request.getParameter("statrD");
	}
	if (endDate == null) {
		endDate = CDGUtil.getCurrentTime().substring(0, 10);
	} else {
		endDate = request.getParameter("endD");
	}
	String subgroupState = RequestUtil.getParameter(request, "subgroupState", "0");
	int currPage = RequestUtil.getIntParameter(request, "curpage", 1);//当前第几页
	
	String organiseId = RequestUtil.getParameter(request, "organiseId","0");
	
	String userEnterId = RequestUtil.getParameter(request, "useId", "");
	String fileName = RequestUtil.getParameter(request, "fileName", "");
	String seachoperate = RequestUtil.getParameter(request, "seachoperate1", "");
	if (userEnterId == null) {
		userEnterId = "";
	}
	if (fileName == null) {
		fileName = "";
	}
	if (seachoperate == null) {
		seachoperate = "";
	}
	FileAuditDao dao=new FileAuditDao();//dao
	
	FileAudit file=new FileAudit();//bean
	file.setUserEnterId(userEnterId);
	file.setFileName(fileName);
	file.setId(loginMng.getUser().getUserId());//用户名id
	file.setSubgroupState(subgroupState);
	PageUtil pageutil = dao.getFileAuditList(file,currPage,organiseId,startDate,endDate,seachoperate) ;
	List<FileAudit> list = pageutil.getRecords();
	
	
	session.setAttribute("maxrowcount", ""+ pageutil.getRecordNum());
	session.setAttribute("maxpage", ""+ (pageutil.getPageNum() != 0 ? pageutil.getPageNum(): 0));
	session.setAttribute("curpage", "" + currPage);
	session.setAttribute("selectTableName","printManager");
	session.setAttribute("statrD", "" + startDate);
	session.setAttribute("endD", "" + endDate);
%>
<html>
	<head>
		<link rel="stylesheet" href="../style/style2/style.css"
			type="text/css">
		<link rel="stylesheet" type="text/css" href="../css/DataGrid.css">
		<script type="text/javascript" src="../js/verify.js"></script>
		<script type="text/javascript" src="../js/commons.js"></script>
		<script type="text/javascript" src="../js/My97DatePicker/WdatePicker.js"></script>
		<script type="text/javascript" src="../js/prototype-1.6.0.2.js"></script>
		<script type="text/javascript">
		var gUrl = '<%=request.getScheme()%>://<%=request.getServerName() + ":"
					+ request.getServerPort() + request.getContextPath() + "/"%>';
		function resetAll(){
			document.getElementById("seachoperate").value = "7";
	   		document.getElementById("userEnterId").value = "";
	   		document.getElementById("seachfileName").value = "";
	   	}
		
	   	function submitForm(){
		   	var thisForm = document.getElementById("myForm");
	    	var startDate =document.getElementById("startDate").value;
	    	var userEnterId =document.getElementById("userEnterId").value;
	    	var fileName1 =document.getElementById("seachfileName").value;   	
	    	var endDate = document.getElementById("endDate").value;
	    	var seachoperate01 = document.getElementById("seachoperate").value;
	    	if(!startDateCompareEndDate(startDate,endDate)) {
	    		document.myForm.endDate.focus();
	    		return false;
	    	}
	    	
	    	var startArray = startDate.split('-');
	        var endArray = endDate.split('-');  
			//判断年份月份必须相等
	        if(startArray[0] != endArray[0] || startArray[1]!=endArray[1]){
	        	alert("<%=rp.getString("sjgl.yjsj.bzckyczqcxszrq") %>");
	        	return false;
	        }
			if(!isRightFileName(seachoperate01)){
	    	   alert("<%=rp.getString("sjgl.wjsj.czfsbnbhzxtsfh") %>:"+"!@#$%^&*()\\/?\'\":<>|");
	    	   return;
	    	}
			if(!isRightFileName(userEnterId)){
	    	   alert("<%=rp.getString("sjgl.wjsj.czrbnbhzxtsfh") %>:"+"!@#$%^&*()\\/?\'\":<>|");
	    	   return;
	    	}
			if(!isRightFileName(fileName1)){
	    	   alert("<%=rp.getString("sjgl.wjsj.wjmbnbhzxtsfh") %>:"+"!@#$%^&*()\\/?\'\":<>|");
	    	   return;
	    	}
			thisForm.statrD.value=startDate;
			thisForm.endD.value=endDate;
			thisForm.useId.value=userEnterId;
			thisForm.fileName.value=fileName1;
			thisForm.seachoperate1.value=seachoperate01;
	    	var crpage = document.getElementById("curpage");
    		if(crpage !=null && crpage!="undefined"&& crpage!="null"){
    			document.getElementById("curpage").value= "1";
    		}
	    	thisForm.action = "fileManager.jsp;jsessionid=<%=session.getId()%>";
	    	thisForm.submit();
	   	}	
	   	
   		function _download(fileName,realPath,appUser){
   		   	document.getElementById("realPath").value=realPath;
        	document.getElementById("fileName").value=fileName;
            document.getElementById("appUser").value=appUser;
			downloadForm.submit();
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
		function EnterPress(e){ //传入 event   
		  var e = e || window.event;   
		  if(e.keyCode == 13){   
		  	submitForm();   
		  }   
		}
		function auditexport(){
			document.getElementById("clrsExport").disabled=true;
			var thisForm = document.getElementById("downloadForm");
	    	var startDate =document.getElementById("startDate").value;
	    	var userEnterId =document.getElementById("userEnterId").value;
	    	var fileName1 =document.getElementById("seachfileName").value;   	
	    	var endDate = document.getElementById("endDate").value;
	    	var seachoperate01 = document.getElementById("seachoperate").value;
	    	if(!startDateCompareEndDate(startDate,endDate)) {
	    		document.myForm.endDate.focus();
	    		return false;
	    	}
	    	
	    	var startArray = startDate.split('-');
	        var endArray = endDate.split('-');  
			//判断年份月份必须相等
	        if(startArray[0] != endArray[0] || startArray[1]!=endArray[1]){
	        	alert("<%=rp.getString("sjgl.yjsj.bzckyczqcxszrq") %>");
	        	return false;
	        }
			if(!isRightFileName(seachoperate01)){
	    	   alert("<%=rp.getString("sjgl.wjsj.czfsbnbhzxtsfh") %>:"+"!@#$%^&*()\\/?\'\":<>|");
	    	   return;
	    	}
			if(!isRightFileName(userEnterId)){
	    	   alert("<%=rp.getString("sjgl.wjsj.czrbnbhzxtsfh") %>:"+"!@#$%^&*()\\/?\'\":<>|");
	    	   return;
	    	}
			if(!isRightFileName(fileName1)){
	    	   alert("<%=rp.getString("sjgl.wjsj.wjmbnbhzxtsfh") %>:"+"!@#$%^&*()\\/?\'\":<>|");
	    	   return;
	    	}
			thisForm.statrD.value=startDate;
			thisForm.endD.value=endDate;
			thisForm.useId.value=userEnterId;
			thisForm.fileName.value=fileName1;
			thisForm.seachoperate1.value=seachoperate01;
			
			document.getElementById("downloadForm").action="<%=request.getContextPath()%>/fileAuditAjax?command=exportFileAudit";
			document.downloadForm.submit();
			document.getElementById("downloadForm").action="fileManager.jsp;jsessionid=<%=session.getId()%>";
			setTimeout(function(){
				document.getElementById("clrsExport").disabled=false;
				},5000);
		}
</script>
	</head>
	<body class="main_frame" >
		<form action="<%=basePath%>/download1" method="post"
			name="downloadForm"  id="downloadForm" >
			<input type="hidden" id="organiseId" name="organiseId" value="<%=organiseId%>">
			<input type="hidden" id="realPath" name="realPath" value="">
			<input type="hidden" id="statrD" name="statrD" value="<%=startDate %>">
			<input type="hidden" id="endD" name="endD" value="<%=endDate %>">
			<input type="hidden" id="useId" name="useId" value="<%=userEnterId %>">
			<input type="hidden" id="fileName" name="fileName" value="<%=fileName %>">
			<input type="hidden" id="seachoperate1" name="seachoperate1" value="<%=seachoperate %>">
			<input type="hidden" name="down" value="true">
			<input type="hidden" id="appUser" name="appUser" value="" />
		</form>
		<form
			action="fileManager.jsp;jsessionid=<%=session.getId()%>"
			method="post" name="myForm" id="myForm">
			<input type="hidden" id="organiseId" name="organiseId" value="<%=organiseId%>">
			<input type="hidden" id="realPath" name="realPath" value="">
			<input type="hidden" id="statrD" name="statrD" value="<%=startDate %>">
			<input type="hidden" id="endD" name="endD" value="<%=endDate %>">
			<input type="hidden" id="useId" name="useId" value="<%=userEnterId %>">
			<input type="hidden" id="fileName" name="fileName" value="<%=fileName %>">
			<input type="hidden" id="seachoperate1" name="seachoperate1" value="<%=seachoperate %>">
			<table align="center" class="DataGrid" border="0" cellpadding="0"
				cellspacing="1" width="95%">
				<thead class="DataGridThead">
					<tr>
						<th colspan="10">
								<%=rp.getString("init.wjsj") %>
						</th>
					</tr>
				</thead>
				<tr class="DataGridRow">
					<td align="right" style="width:10%">
						<%=rp.getString("log.qsrq") %>：
					</td>
					<td align="left" style="width:20%">
						<input type="text" id="startDate" name="startDate"
							style="cursor: hand;" readonly="readonly" style="width:99%" 
							onfocus="var endDate=$dp.$('endDate');WdatePicker({onpicked:function(){endDate.focus();},maxDate:'#F{$dp.$D(\'endDate\')}',dateFmt:'yyyy-MM-dd',lang:'<%=rp.getlanguage() %>'})"
							value="<%=startDate%>">
					</td>
					<td align="right" style="width:15%">
						<%=rp.getString("log.jzrq") %>：
					</td>
					<td align="left" style="width:20%">
						<input type="text" id="endDate" name="endDate" style="cursor: hand;"
							readonly="readonly" style="width:99%" 
							onfocus="WdatePicker({minDate:'#F{$dp.$D(\'startDate\')}',maxDate:'%y-%M-%d',dateFmt:'yyyy-MM-dd',lang:'<%=rp.getlanguage() %>'})"
							value="<%=endDate%>">
					</td>
					<td align="right" style="width:15%">
						<span id="subgroupuser" style="display: none">
							<%=rp.getString("zzry.zzyh") %>：
						</span>	
					</td>
					<td align="left" style="width:20%">
						<span id="subgroupuser1" style="display: none">
							<select name="subgroupState" id="subgroupState" style="width:99%" onkeyup="EnterPress(event)" onblur="checkpolcyselec()">
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
				<tr class="DataGridRow">
					<td align="right" style="width:10%">
						<%=rp.getString("sjgl.wjsj.czfs") %>：
					</td>
					<td align="left" style="width:20%">
						<select style="width:99%" name="seachoperate" id="seachoperate" onkeyup="EnterPress(event)">
							<option value="7" <%if(seachoperate.equals("7")){%>selected="selected" <%}%>><%=rp.getString("zzry.qball")%>
							<option value="0" <%if(seachoperate.equals("0")){%>selected="selected" <%}%>><%=rp.getString("sjgl.wjsj.lzjm")%>
							<option value="1" <%if(seachoperate.equals("1")){%>selected="selected" <%}%>><%=rp.getString("sjgl.wjsj.lzjiem")%>
							<option value="2" <%if(seachoperate.equals("2")){%>selected="selected" <%}%>><%=rp.getString("sjgl.wjsj.lzzh")%>
							<option value="3" <%if(seachoperate.equals("3")){%>selected="selected" <%}%>><%=rp.getString("sjgl.wjsj.yjjm")%>
							<option value="4" <%if(seachoperate.equals("4")){%>selected="selected" <%}%>><%=rp.getString("sjgl.wjsj.yjhy")%>
							<option value="5" <%if(seachoperate.equals("5")){%>selected="selected" <%}%>><%=rp.getString("sjgl.wjsj.jmsq")%>
							<option value="6" <%if(seachoperate.equals("6")){%>selected="selected" <%}%>><%=rp.getString("sjgl.wjsj.wfjm")%>
							<option value="8" <%if(seachoperate.equals("8")){%>selected="selected" <%}%>><%=rp.getString("sjgl.wjsj.sqsq")%>
						</select>
					</td>
					<td align="right" style="width:15%">
						<%=rp.getString("sjgl.wjsj.czr") %>：
					</td>
					<td align="left" style="width:20%">
						<input name="userEnterId" id="userEnterId" type="text" value="<%=userEnterId %>"  style="width: 100%" maxlength="50" onkeyup="EnterPress(event)">
					</td>
					<td align="right" style="width:15%">
						<%=rp.getString("sjgl.wjsj.wjm") %>：
					</td>
					<td align="left" style="width:20%">
						<input name="seachfileName" id="seachfileName" type="text" value="<%=fileName %>"  style="width: 100%" maxlength="50" onkeyup="EnterPress(event)">
					</td>

				</tr>
				<tr class="DataGridThead">
					<td align="center" colspan="10">
						&nbsp;
						<input type="button" name="search" onClick="submitForm();"
							value="<%=rp.getString("global.cx")%><%--查  询--%>">
						&nbsp;
						<input type="button" name="clrsExport" id="clrsExport" onClick="auditexport();"
							value="<%=rp.getString("global.dc")%><%-- 导 出 --%>">
						&nbsp;
						<input type="button" name="clear" onClick="resetAll();"
							value="<%=rp.getString("global.qk")%><%--清  空--%>">
					</td>
				</tr>
			</table>

			<br>
			<table cellspacing="1" cellpadding="0" border="0" width="95%"
				class="DataGrid" id="tbUserList" align="center">
				<thead class="DataGridThead">
					<tr>
						<th style="width:5%" align="center">
							<%=rp.getString("client.xh") %>
						</th>
						<th style="width:28%">
							<%=rp.getString("log.wjmc") %>
						</th>
						<th style="width:12%">
							<%=rp.getString("sjgl.wjsj.wjczrid") %>
						</th>
						<th style="width:13%">
							<%=rp.getString("sjgl.wjsj.wjczrxm") %>
						</th>
						<th style="width:10%">
							<%=rp.getString("sidebar.audit.user.groupName") %>
						</th>
						<th style="width:16%">
							<%=rp.getString("sjgl.wjsj.wjczrq") %>
						</th>
						<th style="width:10%">
							<%=rp.getString("sjgl.wjsj.wjczfs") %>
						</th>
						<th style="width:8%">
							<%=rp.getString("sjgl.wjsj.fjsj") %>
						</th>
					</tr>
				</thead>
				<%
						for (int i = 0;list!=null && i < list.size(); i++) {
							FileAudit fa = list.get(i);
				%>
				<tr class="DataGridRow">
					<td align="center">
						<%=i+1 %>
					</td>
					<td align="center" style="word-wrap:break-word;word-break:break-all">
						<%=fa.getFileName()%>
					</td>
					<td align="center">
						<%=fa.getUserEnterId()%>
					</td>
					<td align="center">
						<%=fa.getSurname()%>
					</td>
					<td align="center">
						<%=fa.getOrganiseName()%>
					</td>
					<td align="center">
						<%=fa.getFileDate()%>
					</td>
					<td align="center">
						<%
						String operateMode = fa.getOperateMode();
						if(operateMode != null){
							if(operateMode.equals("0")){
								operateMode = rp.getString("sjgl.wjsj.lzjm");
							}else if(operateMode.equals("1")){
								operateMode = rp.getString("sjgl.wjsj.lzjiem");
							}else if(operateMode.equals("2")){
								operateMode = rp.getString("sjgl.wjsj.lzzh");
							}else if(operateMode.equals("3")){
								operateMode = rp.getString("sjgl.wjsj.yjjm");
							}else if(operateMode.equals("4")){
								operateMode = rp.getString("sjgl.wjsj.yjhy");
							}else if(operateMode.equals("5")){
								operateMode = rp.getString("sjgl.wjsj.jmsq");
							}else if(operateMode.equals("6")){
								operateMode = rp.getString("sjgl.wjsj.wfjm");
							}else if(operateMode.equals("8")){
								operateMode = rp.getString("sjgl.wjsj.sqsq");
							}
						}
						%>
						<%=operateMode%>
					</td>
					<%  String filename = fa.getFileName();
						String last = fa.getFileCopy().substring(fa.getFileCopy().lastIndexOf("."));
						filename = filename.substring(0,filename.indexOf("."))+last;
						fa.setFileName(filename);
					%>
					<td align="center">
						<a href="#" onclick="_download('<%=fa.getFileName()%>','<%=fa.getFileCopy()%>','<%=fa.getUserEnterId()%>');" ><%=rp.getString("cdg.xz")%></a>
					</td>
				</tr>
				<%
					}
				%>
				<tr class="DataGridRow">
					<td colspan="8" align="right">
						<%@include file="../common/page.jsp"%>
					</td>
							
				</tr>
				<tr class="DataGridThead">
					<td colspan="10" align="center">
					</td>
				</tr>
			</table>
		</form>
<script type="text/javascript">
if("0"==='<%=organiseId%>'){
	document.getElementById("subgroupuser").style.display = "none";
	document.getElementById("subgroupuser1").style.display = "none";
	
}else{
	document.getElementById("subgroupuser").style.display = "";
	document.getElementById("subgroupuser1").style.display = "";
}
</script>
	</body>
</html>
