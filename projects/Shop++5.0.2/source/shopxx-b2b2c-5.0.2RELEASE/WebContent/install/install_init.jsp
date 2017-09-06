<%@page language="java" contentType="text/html;charset=utf-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.Date"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="org.apache.commons.lang.StringUtils"%>
<%@page import="org.apache.commons.lang.BooleanUtils"%>
<%@page import="org.apache.commons.lang.exception.ExceptionUtils"%>
<%@page import="org.apache.commons.io.IOUtils"%>
<%@page import="org.apache.commons.codec.digest.DigestUtils"%>
<%@page import="net.shopxx.util.FreeMarkerUtils"%>
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
	String adminUsername = (String) session.getAttribute("adminUsername");
	String adminPassword = (String) session.getAttribute("adminPassword");
	
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
	} else if (StringUtils.isEmpty(adminUsername)) {
		failed = true;
		message = "管理员用户名不允许为空!";
	} else if (adminUsername.length() < 2 || adminUsername.length() > 20) {
		failed = true;
		message = "管理员用户名长度必须在2-20之间!";
	} else if (StringUtils.isEmpty(adminPassword)) {
		failed = true;
		message = "管理员密码不允许为空!";
	} else if (adminPassword.length() < 4 || adminPassword.length() > 40) {
		failed = true;
		message = "管理员密码长度必须在4-20之间!";
	}
	
	String jdbcUrl = null;
	File sqlFile = null;
	
	if (!failed) {
		if ("mysql".equals(databaseType)) {
			jdbcUrl = "jdbc:mysql://" + databaseHost + ":" + databasePort + "/" + databaseName + "?useUnicode=true&characterEncoding=UTF-8";
			sqlFile = new File(application.getRealPath("/install/data/mysql/init.sql"));
		} else if ("sqlserver".equals(databaseType)) {
			jdbcUrl = "jdbc:sqlserver://" + databaseHost + ":" + databasePort + ";DatabaseName=" + databaseName;
			sqlFile = new File(application.getRealPath("/install/data/sqlserver/init.sql"));
		} else if ("oracle".equals(databaseType)) {
			jdbcUrl = "jdbc:oracle:thin:@" + databaseHost + ":" + databasePort + ":" + databaseName;
			sqlFile = new File(application.getRealPath("/install/data/oracle/init.sql"));
		} else {
			failed = true;
			message = "参数错误!";
		}
	}
	
	if (!failed && (sqlFile == null || !sqlFile.exists() || !sqlFile.isFile())) {
		failed = true;
		message = "INIT.SQL文件不存在!";
	}
	
	if (!failed) {
		Connection connection = null;
		Statement statement = null;
		String currentSQL = null;
		
		try {
			connection = DriverManager.getConnection(jdbcUrl, databaseUsername, databasePassword);
			connection.setAutoCommit(false);
			statement = connection.createStatement();
			
			Map<String, Object> model = new HashMap<String, Object>();
			model.put("base", base);
			model.put("adminUsername", adminUsername);
			model.put("adminPassword", DigestUtils.md5Hex(adminPassword));
			model.put("demoImageUrlPrefix", demoImageUrlPrefix);
			Calendar calendar = Calendar.getInstance();
			calendar.setTime(new Date());
			calendar.set(Calendar.HOUR_OF_DAY, calendar.getActualMinimum(Calendar.HOUR_OF_DAY));
			calendar.set(Calendar.MINUTE, calendar.getActualMinimum(Calendar.MINUTE));
			calendar.set(Calendar.SECOND, calendar.getActualMinimum(Calendar.SECOND));
			
			BufferedReader reader = null;
			try {
				reader = new BufferedReader(new InputStreamReader(new FileInputStream(sqlFile), "UTF-8"));
				String line;
				while ((line = reader.readLine()) != null) {
					if (StringUtils.isNotBlank(line) && !line.startsWith("--")) {
						calendar.add(Calendar.SECOND, 1);
						model.put("date", calendar.getTime());
						currentSQL = FreeMarkerUtils.process(line, model);
						statement.executeUpdate(currentSQL);
					}
				}
			} finally {
				IOUtils.closeQuietly(reader);
			}
			connection.commit();
			currentSQL = null;
		} catch (SQLException e) {
			failed = true;
			message = "JDBC执行错误!";
			stackTrace = ExceptionUtils.getStackTrace(e);
			if (currentSQL != null) {
				stackTrace = "SQL: " + currentSQL + "<br />" + stackTrace;
			}
		} catch (IOException e) {
			failed = true;
			message = "INIT.SQL文件读取失败!";
			stackTrace = ExceptionUtils.getStackTrace(e);
		} finally {
			try {
				if (statement != null) {
					statement.close();
					statement = null;
				}
				if (connection != null) {
					connection.close();
					connection = null;
				}
			} catch (SQLException e) {
			}
		}
	}
	
	Map<String, Object> data = new HashMap<String, Object>();
	data.put("failed", failed);
	data.put("message", message);
	data.put("stackTrace", stackTrace.replaceAll("\\r?\\n", "</br>"));
	JsonUtils.writeValue(response.getWriter(), data);
%>