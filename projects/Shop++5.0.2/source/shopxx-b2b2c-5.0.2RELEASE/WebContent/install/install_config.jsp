<%@page language="java" contentType="text/html;charset=utf-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Properties"%>
<%@page import="java.util.Enumeration"%>
<%@page import="org.apache.commons.lang.StringUtils"%>
<%@page import="org.apache.commons.lang.BooleanUtils"%>
<%@page import="org.apache.commons.lang.exception.ExceptionUtils"%>
<%@page import="org.apache.commons.io.FileUtils"%>
<%@page import="org.apache.commons.io.IOUtils"%>
<%@page import="org.dom4j.Document"%>
<%@page import="org.dom4j.Element"%>
<%@page import="org.dom4j.io.OutputFormat"%>
<%@page import="org.dom4j.io.XMLWriter"%>
<%@page import="org.dom4j.io.SAXReader"%>
<%@page import="net.shopxx.util.JsonUtils"%>
<%@include file="common.jsp"%>
<%
	Boolean agreeAgreement = (Boolean) session.getAttribute("agreeAgreement");
	if (BooleanUtils.isNotTrue(agreeAgreement)) {
		response.sendRedirect("index.jsp");
		return;
	}
	
	String databaseType = (String) session.getAttribute("databaseType");
	String databaseHost = (String) session.getAttribute("databaseHost");
	String databasePort = (String) session.getAttribute("databasePort");
	String databaseUsername = (String) session.getAttribute("databaseUsername");
	String databasePassword = (String) session.getAttribute("databasePassword");
	String databaseName = (String) session.getAttribute("databaseName");
	String locale = (String) session.getAttribute("locale");
	
	boolean failed = false;
	String message = "";
	String stackTrace = "";
	
	if (StringUtils.isEmpty(databaseType)) {
		failed = true;
		message = "数据库类型不允许为空!";
	} else if (StringUtils.isEmpty(databaseHost)) {
		failed = true;
		message = "数据库主机不允许为空!";
	} else if (StringUtils.isEmpty(databasePort)) {
		failed = true;
		message = "数据库端口不允许为空!";
	} else if (StringUtils.isEmpty(databaseUsername)) {
		failed = true;
		message = "数据库用户名不允许为空!";
	} else if (StringUtils.isEmpty(databaseName)) {
		failed = true;
		message = "数据库名称不允许为空!";
	} else if (StringUtils.isEmpty(locale)) {
		failed = true;
		message = "语言不允许为空!";
	}
	
	String jdbcDriver = null;
	String jdbcUrl = null;
	Integer databaseMajorVersion = null;
	Integer databaseMinorVersion = null;
	String hibernateDialect = null;
	
	if (!failed) {
		if ("mysql".equals(databaseType)) {
			jdbcDriver = "com.mysql.jdbc.Driver";
			jdbcUrl = "jdbc:mysql://" + databaseHost + ":" + databasePort + "/" + databaseName + "?useUnicode=true&characterEncoding=UTF-8";
		} else if ("sqlserver".equals(databaseType)) {
			jdbcDriver = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
			jdbcUrl = "jdbc:sqlserver://" + databaseHost + ":" + databasePort + ";databasename=" + databaseName;
		} else if ("oracle".equals(databaseType)) {
			jdbcDriver = "oracle.jdbc.OracleDriver";
			jdbcUrl = "jdbc:oracle:thin:@" + databaseHost + ":" + databasePort + ":" + databaseName;
		} else {
			failed = true;
			message = "参数错误!";
		}
	}
	
	if (!failed) {
		Connection connection = null;
		try {
			connection = DriverManager.getConnection(jdbcUrl, databaseUsername, databasePassword);
			DatabaseMetaData databaseMetaData = connection.getMetaData();
			databaseMajorVersion = databaseMetaData.getDatabaseMajorVersion();
			databaseMinorVersion = databaseMetaData.getDatabaseMinorVersion();
		} catch (SQLException e) {
			failed = true;
			message = "JDBC执行错误!";
			stackTrace = ExceptionUtils.getStackTrace(e);
		} finally {
			try {
				if (connection != null) {
					connection.close();
					connection = null;
				}
			} catch (SQLException e) {
			}
		}
	}
	
	if (!failed) {
		if ("mysql".equals(databaseType)) {
			hibernateDialect = "org.hibernate.dialect.MySQLDialect";
		} else if ("sqlserver".equals(databaseType)) {
			if (databaseMajorVersion == 9) {
				hibernateDialect = "org.hibernate.dialect.SQLServer2005Dialect";
			} else if (databaseMajorVersion == 10) {
				hibernateDialect = "org.hibernate.dialect.SQLServer2008Dialect";
			} else {
				hibernateDialect = "org.hibernate.dialect.SQLServerDialect";
			}
		} else if ("oracle".equals(databaseType)) {
			if (databaseMajorVersion == 8) {
				hibernateDialect = "org.hibernate.dialect.Oracle8iDialect";
			} else if (databaseMajorVersion == 9) {
				hibernateDialect = "org.hibernate.dialect.Oracle9Dialect";
			} else if (databaseMajorVersion == 10) {
				hibernateDialect = "org.hibernate.dialect.Oracle10gDialect";
			} else if (databaseMajorVersion == 11) {
				hibernateDialect = "org.hibernate.dialect.Oracle10gDialect";
			} else {
				hibernateDialect = "org.hibernate.dialect.OracleDialect";
			}
		}
		
		InputStream inputStream = null;
		OutputStream outputStream = null;
		try {
			Properties properties = new Properties();
			inputStream = new FileInputStream(shopxxPropertiesFile);
			properties.load(inputStream);
			properties.setProperty("jdbc.driver", jdbcDriver);
			properties.setProperty("jdbc.url", jdbcUrl);
			properties.setProperty("jdbc.username", databaseUsername);
			properties.setProperty("jdbc.password", databasePassword);
			properties.setProperty("hibernate.dialect", hibernateDialect);
			outputStream = new FileOutputStream(shopxxPropertiesFile);
			properties.store(outputStream, "SHOP++ PROPERTIES");
		} catch (IOException e) {
			failed = true;
			message = "SHOPXX.PROPERTIES文件写入失败!";
			stackTrace = ExceptionUtils.getStackTrace(e);
		} finally {
			IOUtils.closeQuietly(inputStream);
			IOUtils.closeQuietly(outputStream);
		}
	}
	
	if (!failed) {
		Document document = new SAXReader().read(shopxxXmlFile);
		Element siteUrlElement = (Element) document.selectSingleNode("/shopxx/setting[@name='siteUrl']");
		Element logoElement = (Element) document.selectSingleNode("/shopxx/setting[@name='logo']");
		Element defaultLargeProductImageElement = (Element) document.selectSingleNode("/shopxx/setting[@name='defaultLargeProductImage']");
		Element defaultMediumProductImageElement = (Element) document.selectSingleNode("/shopxx/setting[@name='defaultMediumProductImage']");
		Element defaultThumbnailProductImageElement = (Element) document.selectSingleNode("/shopxx/setting[@name='defaultThumbnailProductImage']");
		Element defaultStoreLogoElement = (Element) document.selectSingleNode("/shopxx/setting[@name='defaultStoreLogo']");
		Element localeElement = (Element) document.selectSingleNode("/shopxx/setting[@name='locale']");
		String siteUrl;
		if (request.getServerPort() == 80) {
			siteUrl = request.getScheme() + "://" + request.getServerName() + base;
		} else {
			siteUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + base;
		}
		siteUrlElement.attribute("value").setValue(siteUrl);
		logoElement.attribute("value").setValue(base + "/upload/image/logo.png");
		defaultLargeProductImageElement.attribute("value").setValue(base + "/upload/image/default_large.jpg");
		defaultMediumProductImageElement.attribute("value").setValue(base + "/upload/image/default_medium.jpg");
		defaultThumbnailProductImageElement.attribute("value").setValue(base + "/upload/image/default_thumbnail.jpg");
		defaultStoreLogoElement.attribute("value").setValue(base + "/upload/image/default_store_logo.jpg");
		localeElement.attribute("value").setValue(locale);
		
		XMLWriter xmlWriter = null;
		try {
			OutputFormat outputFormat = OutputFormat.createPrettyPrint();
			outputFormat.setEncoding("UTF-8");
			outputFormat.setIndent(true);
			outputFormat.setIndent("	");
			outputFormat.setNewlines(true);
			xmlWriter = new XMLWriter(new FileOutputStream(shopxxXmlFile), outputFormat);
			xmlWriter.write(document);
			xmlWriter.flush();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if (xmlWriter != null) {
					xmlWriter.close();
				}
			} catch (IOException e) {
			}
		}
	}
	
	if (!failed) {
		try {
			FileUtils.writeStringToFile(installLockConfigFile, "SHOP++ INSTALL LOCK - SHOPXX.NET", "UTF-8");
		} catch (IOException e) {
			failed = true;
			message = "INSTALL_LOCK.CONFIG文件写入失败!";
			stackTrace = ExceptionUtils.getStackTrace(e);
		}
	}
	
	if (!failed) {
		try {
			FileUtils.copyFile(webXmlSampleFile, webXmlFile);
		} catch (IOException e) {
			failed = true;
			message = "WEB.XML文件写入失败!";
			stackTrace = ExceptionUtils.getStackTrace(e);
		}
	}
	
	Enumeration<Driver> drivers = DriverManager.getDrivers();
	while (drivers.hasMoreElements()) {
		Driver driver = drivers.nextElement();
		try {
			DriverManager.deregisterDriver(driver);
		} catch (SQLException e) {
		}
	}
	
	Map<String, Object> data = new HashMap<String, Object>();
	data.put("failed", failed);
	data.put("message", message);
	data.put("stackTrace", stackTrace.replaceAll("\\r?\\n", "</br>"));
	JsonUtils.writeValue(response.getWriter(), data);
%>