<%@page language="java" contentType="text/html;charset=utf-8" pageEncoding="UTF-8"%>
<%@page import="java.io.*"%>
<%
	response.setHeader("Pragma", "no-cache");
	response.setHeader("Cache-Control", "no-cache");
	response.setHeader("Cache-Control", "no-store");
	response.setDateHeader("Expires", 0);
	
	String base = request.getContextPath();
	File webXmlFile = new File(application.getRealPath("/WEB-INF/web.xml"));
	File webXmlSampleFile = new File(application.getRealPath("/install/sample/web.xml"));
	File shopxxXmlFile = new File(application.getRealPath("/WEB-INF/classes/shopxx.xml"));
	File shopxxPropertiesFile = new File(application.getRealPath("/WEB-INF/classes/shopxx.properties"));
	File installInitConfigFile = new File(application.getRealPath("/install_init.conf"));
	File installLockConfigFile = new File(application.getRealPath("/install/install_lock.conf"));
	File indexJspFile = new File(application.getRealPath("/index.jsp"));
	String demoImageUrlPrefix = "http://image.demo.shopxx.net/b2b2c/5.0";
	
	if(installLockConfigFile.exists()) {
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="content-type" content="text/html;charset=utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<title>系统提示 - Powered By SHOP++</title>
<meta name="author" content="SHOP++ Team" />
<meta name="copyright" content="SHOP++" />
<link href="css/install.css" rel="stylesheet" type="text/css" />
</head>
<body>
	<fieldset>
		<legend>系统提示</legend>
		<p>您无此访问权限！若您需要重新安装SHOP++程序，请删除/install/install_lock.conf文件！ [<a href="<%=base%>/">进入首页</a>]</p>
		<p>
			<strong>提示: 基于安全考虑请在安装成功后删除install目录</strong>
		</p>
	</fieldset>
</body>
</html>
<%
		return;
	}
%>