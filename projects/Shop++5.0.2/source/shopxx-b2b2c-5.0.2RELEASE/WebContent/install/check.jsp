<%@page language="java" contentType="text/html;charset=utf-8" pageEncoding="UTF-8"%>
<%@page import="org.apache.commons.lang.StringUtils"%>
<%@page import="org.apache.commons.io.FileSystemUtils"%>
<%@page import="org.apache.commons.io.FileUtils"%>
<%@include file="common.jsp"%>
<%
	String agreeAgreement = request.getParameter("agreeAgreement");
	if ("true".equals(agreeAgreement)) {
		session.setAttribute("agreeAgreement", true);
	} else {
		response.sendRedirect("index.jsp");
		return;
	}
	
	boolean invalid = false;
	
	String jdkVersionInfo = System.getProperty("java.version");
	try {
		String jdkVersion = System.getProperty("java.specification.version");
		String[] jdkVersions = StringUtils.split(jdkVersion, ".");
		if (jdkVersions.length > 1) {
			int jdkMajorVersion = Integer.valueOf(jdkVersions[0]);
			int jdkMinorVersion = Integer.valueOf(jdkVersions[1]);
			if ((jdkMajorVersion == 1 && jdkMinorVersion >= 7) || jdkMajorVersion > 1) {
				jdkVersionInfo = "<span class=\"green\">" + jdkVersionInfo + "</span>";
			} else {
				invalid = true;
				jdkVersionInfo = "<span class=\"red\">" + jdkVersionInfo + "</span>";
			}
		}
	} catch (Exception e) {
	}
	
	String servletVersionInfo = StringUtils.substring(application.getServerInfo(), 0, 25);
	try {
		int servletMajorVersion = application.getMajorVersion();
		int servletMinorVersion = application.getMinorVersion();
		if (servletMajorVersion >= 3) {
			servletVersionInfo = "<span class=\"green\">" + servletVersionInfo + "</span>";
		} else {
			invalid = true;
			servletVersionInfo = "<span class=\"red\">" + servletVersionInfo + "</span>";
		}
	} catch (Exception e) {
	}
	
	String freeSpaceInfo = "-";
	try {
		long freeSpace = FileSystemUtils.freeSpaceKb(application.getRealPath("/"));
		if (freeSpace < 512 * 1024) {
			invalid = true;
			freeSpaceInfo = "<span class=\"red\">" + FileUtils.byteCountToDisplaySize(freeSpace * 1024) + "</span>";
		} else {
			freeSpaceInfo = "<span class=\"green\">" + FileUtils.byteCountToDisplaySize(freeSpace * 1024) + "</span>";
		}
	} catch (Exception e) {
	}
	
	String maxMemoryInfo = "-";
	try {
		double maxMemory = Runtime.getRuntime().maxMemory() / 1024 / 1024;
		if (maxMemory < 200) {
			invalid = true;
			maxMemoryInfo = "<span class=\"red\">" + maxMemory + "MB</span>";
		} else {
			maxMemoryInfo = "<span class=\"green\">" + maxMemory + "MB</span>";
		}
	} catch (Exception e) {
	}
	
	String webXmlInfo;
	if (webXmlFile.canWrite()) {
		webXmlInfo = "<span class=\"green\">√</span>";
	} else {
		invalid = true;
		webXmlInfo = "<span class=\"red\">×</span>";
	}
	
	String shopxxXmlInfo;
	if (shopxxXmlFile.canWrite()) {
		shopxxXmlInfo = "<span class=\"green\">√</span>";
	} else {
		invalid = true;
		shopxxXmlInfo = "<span class=\"red\">×</span>";
	}
	
	String shopxxPropertiesInfo;
	if (shopxxPropertiesFile.canWrite()) {
		shopxxPropertiesInfo = "<span class=\"green\">√</span>";
	} else {
		invalid = true;
		shopxxPropertiesInfo = "<span class=\"red\">×</span>";
	}
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="content-type" content="text/html;charset=utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<title>检查安装环境 - Powered By SHOP++</title>
<meta name="author" content="SHOP++ Team" />
<meta name="copyright" content="SHOP++" />
<link href="css/install.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="js/jquery.js"></script>
<script type="text/javascript">
$().ready( function() {

	var $encodingInfo = $("#encodingInfo");
	var $previous = $("#previous");
	var $next = $("#next");
	var invalid = <%=invalid%>;
	
	$.ajax({
		type: "GET",
		cache: false,
		url: "check_encoding.jsp",
		data: {value: "一"},
		dataType: "json",
		beforeSend: function(data) {
			$encodingInfo.text("-");
		},
		success: function(data) {
			if (data) {
				$encodingInfo.html('<span class="green">√<\/span>');
			} else {
				$encodingInfo.html('<span class="red">×<\/span>');
				invalid = true;
			}
		}
	});
	
	$previous.click(function() {
		location.href = "index.jsp";
	});
	
	$next.click(function() {
		if (invalid && !confirm("您的安装环境有误,可能导致系统安装或运行错误,您确定继续吗?")) {
			return false;
		} else {
			location.href = "setting.jsp";
		}
	});

});
</script>
</head>
<body>
	<div class="header">
		<div class="title">SHOP++ 安装程序 - 环境检测</div>
		<div class="banner"></div>
	</div>
	<div class="body">
		<div class="bodyLeft">
			<ul class="step">
				<li>许可协议</li>
				<li class="current">环境检测</li>
				<li>系统配置</li>
				<li>系统安装</li>
				<li>完成安装</li>
			</ul>
		</div>
		<div class="bodyRight">
			<table>
				<tr>
					<th>&nbsp;</th>
					<th>基本环境</th>
					<th>推荐环境</th>
					<th>当前环境</th>
				</tr>
				<tr>
					<td>
						<strong>操作系统:</strong>
					</td>
					<td>
						Linux/Unix/Windows ...
					</td>
					<td>
						Linux/Unix/Windows
					</td>
					<td>
						<%=System.getProperty("os.name")%> (<%=System.getProperty("os.arch")%>)
					</td>
				</tr>
				<tr>
					<td>
						<strong>JDK版本:</strong>
					</td>
					<td>
						JDK 1.7 +
					</td>
					<td>
						JDK 1.7
					</td>
					<td>
						<%=jdkVersionInfo%>
					</td>
				</tr>
				<tr>
					<td>
						<strong>WEB服务器:</strong>
					</td>
					<td>
						Tomcat 7.0 +
					</td>
					<td>
						Tomcat 7.0
					</td>
					<td>
						<%=servletVersionInfo%>
					</td>
				</tr>
				<tr>
					<td>
						<strong>数据库:</strong>
					</td>
					<td>
						MySQL/Oracle/SQL Server
					</td>
					<td>
						MySQL 5.5
					</td>
					<td>
						-
					</td>
				</tr>
				<tr>
					<td>
						<strong>磁盘空间:</strong>
					</td>
					<td>
						512MB +
					</td>
					<td>
						1024MB
					</td>
					<td>
						<%=freeSpaceInfo%>
					</td>
				</tr>
				<tr>
					<td>
						<strong>可用内存:</strong>
					</td>
					<td>
						256MB +
					</td>
					<td>
						1024MB
					</td>
					<td>
						<%=maxMemoryInfo%>
					</td>
				</tr>
				<tr>
					<td>
						<strong>字符集编码:</strong>
					</td>
					<td>
						UTF-8
					</td>
					<td>
						UTF-8
					</td>
					<td>
						<span id="encodingInfo"></span>
					</td>
				</tr>
			</table>
			<table>
				<tr>
					<th width="344">
						文件目录
					</th>
					<th width="170">
						所需状态
					</th>
					<th>
						当前状态
					</th>
				</tr>
				<tr>
					<td>
						/WEB-INF/web.xml
					</td>
					<td>
						可写
					</td>
					<td>
						<%=webXmlInfo%>
					</td>
				</tr>
				<tr>
					<td>
						/WEB-INF/classes/shopxx.xml
					</td>
					<td>
						可写
					</td>
					<td>
						<%=shopxxXmlInfo%>
					</td>
				</tr>
				<tr>
					<td>
						/WEB-INF/classes/shopxx.properties
					</td>
					<td>
						可写
					</td>
					<td>
						<%=shopxxPropertiesInfo%>
					</td>
				</tr>
			</table>
		</div>
		<div class="buttonArea">
			<input type="button" id="previous" class="button" value="上 一 步" />&nbsp;&nbsp;&nbsp;&nbsp;
			<input type="button" id="next" class="button" value="下 一 步" />
		</div>
	</div>
	<div class="footer">
		<p class="copyright">Copyright © 2005-2017 shopxx.net All Rights Reserved.</p>
	</div>
</body>
</html>