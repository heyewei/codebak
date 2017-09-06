<%@page language="java" contentType="text/html;charset=utf-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="org.apache.commons.lang.StringUtils"%>
<%@page import="org.apache.commons.lang.BooleanUtils"%>
<%@page import="org.apache.commons.lang.exception.ExceptionUtils"%>
<%@include file="common.jsp"%>
<%
	Boolean agreeAgreement = (Boolean) session.getAttribute("agreeAgreement");
	if (BooleanUtils.isNotTrue(agreeAgreement)) {
		response.sendRedirect("index.jsp");
		return;
	}
	
	String databaseType = StringUtils.trim(request.getParameter("databaseType"));
	String databaseHost = StringUtils.trim(request.getParameter("databaseHost"));
	String databasePort = StringUtils.trim(request.getParameter("databasePort"));
	String databaseUsername = StringUtils.trim(request.getParameter("databaseUsername"));
	String databasePassword = StringUtils.trim(request.getParameter("databasePassword"));
	String databaseName = StringUtils.trim(request.getParameter("databaseName"));
	String adminUsername = StringUtils.trim(request.getParameter("adminUsername"));
	String adminPassword = StringUtils.trim(request.getParameter("adminPassword"));
	String locale = StringUtils.trim(request.getParameter("locale"));
	String createDatabase = StringUtils.trim(request.getParameter("createDatabase"));
	String importDemo = StringUtils.trim(request.getParameter("importDemo"));
	
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
	} else if (StringUtils.isEmpty(locale)) {
		failed = true;
		message = "语言不允许为空!";
	}
	
	if (!failed) {
		session.setAttribute("databaseType", databaseType);
		session.setAttribute("databaseHost", databaseHost);
		session.setAttribute("databasePort", databasePort);
		session.setAttribute("databaseUsername", databaseUsername);
		session.setAttribute("databasePassword", databasePassword);
		session.setAttribute("databaseName", databaseName);
		session.setAttribute("adminUsername", adminUsername);
		session.setAttribute("adminPassword", adminPassword);
		session.setAttribute("locale", locale);
		session.setAttribute("createDatabase", createDatabase);
		session.setAttribute("importDemo", importDemo);
		
		Connection connection = null;
		
		try {
			if ("mysql".equals(databaseType)) {
				try {
					Class.forName("com.mysql.jdbc.Driver");
				} catch (Exception e) {
					failed = true;
					message = "MySQL JDBC驱动加载失败,请检查JDBC驱动!";
					stackTrace = ExceptionUtils.getStackTrace(e);
				}
				
				if (!failed) {
					if ("true".equals(createDatabase)) {
						List<String> jdbcUrls = new ArrayList<String> ();
						jdbcUrls.add("jdbc:mysql://" + databaseHost + ":" + databasePort + "/" + databaseName + "?useUnicode=true&characterEncoding=UTF-8");
						jdbcUrls.add("jdbc:mysql://" + databaseHost + ":" + databasePort + "/" + databaseName + "?useUnicode=true");
						jdbcUrls.add("jdbc:mysql://" + databaseHost + ":" + databasePort + "/mysql?useUnicode=true&characterEncoding=UTF-8");
						jdbcUrls.add("jdbc:mysql://" + databaseHost + ":" + databasePort + "/mysql?useUnicode=true");
						jdbcUrls.add("jdbc:mysql://" + databaseHost + ":" + databasePort + "/test?useUnicode=true&characterEncoding=UTF-8");
						jdbcUrls.add("jdbc:mysql://" + databaseHost + ":" + databasePort + "/test?useUnicode=true");
						for (String jdbcUrl : jdbcUrls) {
							try {
								connection = DriverManager.getConnection(jdbcUrl, databaseUsername, databasePassword);
								failed = false;
								message = "";
								stackTrace = "";
								break;
							} catch (SQLException e) {
								failed = true;
								message = "数据库连接失败,请检查数据库用户名、密码等配置信息!";
								stackTrace = ExceptionUtils.getStackTrace(e);
								continue;
							}
						}
					} else {
						try {
							String jdbcUrl = "jdbc:mysql://" + databaseHost + ":" + databasePort + "/" + databaseName + "?useUnicode=true&characterEncoding=UTF-8";
							connection = DriverManager.getConnection(jdbcUrl, databaseUsername, databasePassword);
						} catch (SQLException e0) {
							try {
								String jdbcUrl = "jdbc:mysql://" + databaseHost + ":" + databasePort + "/" + databaseName + "?useUnicode=true";
								connection = DriverManager.getConnection(jdbcUrl, databaseUsername, databasePassword);
							} catch (SQLException e1) {
								failed = true;
								message = "数据库连接失败,请检查数据库用户名、密码等配置信息!";
								stackTrace = ExceptionUtils.getStackTrace(e1);
							}
						}
					}
				}
			} else if ("sqlserver".equals(databaseType)) {
				try {
					Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
				} catch (Exception e) {
					failed = true;
					message = "SQL Server JDBC驱动加载失败,请检查JDBC驱动!";
					stackTrace = ExceptionUtils.getStackTrace(e);
				}
				
				if (!failed) {
					try {
						String jdbcUrl = "jdbc:sqlserver://" + databaseHost + ":" + databasePort + ";databasename=" + databaseName;
						connection = DriverManager.getConnection(jdbcUrl, databaseUsername, databasePassword);
					} catch (SQLException e) {
						failed = true;
						message = "数据库连接失败,请检查数据库用户名、密码等配置信息!";
						stackTrace = ExceptionUtils.getStackTrace(e);
					}
				}
			} else if ("oracle".equals(databaseType)) {
				try {
					Class.forName("oracle.jdbc.OracleDriver");
				} catch (Exception e) {
					failed = true;
					message = "Oracle JDBC驱动加载失败,请检查JDBC驱动!";
					stackTrace = ExceptionUtils.getStackTrace(e);
				}
				
				if (!failed) {
					try {
						String jdbcUrl = "jdbc:oracle:thin:@" + databaseHost + ":" + databasePort + ":" + databaseName;
						connection = DriverManager.getConnection(jdbcUrl, databaseUsername, databasePassword);
					} catch (SQLException e) {
						failed = true;
						message = "数据库连接失败,请检查数据库用户名、密码等配置信息!";
						stackTrace = ExceptionUtils.getStackTrace(e);
					}
				}
			}
			
			if (!failed && connection != null) {
				try {
					DatabaseMetaData databaseMetaData = connection.getMetaData();
					int databaseMajorVersion = databaseMetaData.getDatabaseMajorVersion();
					int databaseMinorVersion = databaseMetaData.getDatabaseMinorVersion();
					if ("mysql".equals(databaseType) && (databaseMajorVersion < 5 || (databaseMajorVersion == 5 && databaseMinorVersion < 5))) {
						failed = true;
						message = "系统不支持该MySQL版本!";
					} else if ("sqlserver".equals(databaseType) && databaseMajorVersion < 9) {
						failed = true;
						message = "系统不支持该SQL Server版本!";
					} else if ("oracle".equals(databaseType) && databaseMajorVersion < 11) {
						failed = true;
						message = "系统不支持该Oracle版本!";
					}
				} catch (SQLException e) {
					failed = true;
					message = "JDBC执行错误!";
					stackTrace = ExceptionUtils.getStackTrace(e);
				}
				
				if (!failed && "mysql".equals(databaseType) && "true".equals(createDatabase)) {
					Statement statement = connection.createStatement();
					try {
						statement.executeUpdate("create database if not exists `" + databaseName + "` default character set utf8");
					} catch (SQLException e) {
						failed = true;
						message = "自动创建数据库失败，请手动创建数据库!";
						stackTrace = ExceptionUtils.getStackTrace(e);
					} finally {
						try {
							if(statement != null) {
								statement.close();
								statement = null;
							}
						} catch (SQLException e) {
						}
					}
				}
			}
		} finally {
			try {
				if(connection != null) {
					connection.close();
					connection = null;
				}
			} catch (SQLException e) {
			}
		}
	}
	
	String homeUrl = null;
	String adminUrl = null;
	if (request.getServerPort() == 80) {
		homeUrl = request.getScheme() + "://" + request.getServerName() + base;
		adminUrl = request.getScheme() + "://" + request.getServerName() + base + "/admin";
	} else {
		homeUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + base;
		adminUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + base + "/admin";
	}
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="content-type" content="text/html;charset=utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<title>SHOP++安装程序 - Powered By SHOP++</title>
<meta name="author" content="SHOP++ Team" />
<meta name="copyright" content="SHOP++" />
<link href="css/install.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="js/jquery.js"></script>
</head>
<body>
	<div class="header">
		<div class="title">SHOP++ 安装程序</div>
		<div class="banner"></div>
	</div>
	<div class="body">
		<div class="bodyLeft">
			<ul class="step">
				<li>许可协议</li>
				<li>环境检测</li>
				<li>系统配置</li>
				<li id="installStep" class="current">系统安装</li>
				<li id="completeStep">完成安装</li>
			</ul>
		</div>
		<div class="bodyRight">
			<%
				if (failed) {
			%>
			<table>
				<tr>
					<th>
						系统提示
					</th>
				</tr>
				<tr>
					<td>
						<strong class="message"><%=message%></strong>
					</td>
				</tr>
			</table>
			<table>
				<tr>
					<th>
						异常信息
					</th>
				</tr>
				<tr>
					<td style="padding: 0px;">
						<div class="stackTrace">
							<%=stackTrace%>
						</div>
					</td>
				</tr>
			</table>
			<%
				} else {
			%>
			<table>
				<tr>
					<th>
						安装提示
					</th>
				</tr>
				<tr>
					<td>
						<div id="installMessage">正在检测数据库环境...</div>
						<div id="installLoading" class="loadingBar">&nbsp;</div>
						<div id="installUrl" class="installUrl">
							<div>
								用户前台地址: <a href="<%=homeUrl%>" target="_blank"><%=homeUrl%></a>
							</div>
							<div>
								管理后台地址: <a href="<%=adminUrl%>" target="_blank"><%=adminUrl%></a>
							</div>
						</div>
					</td>
				</tr>
			</table>
			<table style="display: none;">
				<tr>
					<th>
						异常信息
					</th>
				</tr>
				<tr>
					<td style="padding: 0px;">
						<div id="installStackTrace" class="stackTrace">
							<%=stackTrace%>
						</div>
					</td>
				</tr>
			</table>
			<%
				}
			%>
		</div>
		<div class="buttonArea">
			<input type="button" id="previous" class="button" value="上 一 步" onclick="location.href='setting.jsp'" />&nbsp;&nbsp;&nbsp;&nbsp;
			<input type="button" id="complete" class="button" value="完成安装" disabled="disabled" />
		</div>
	</div>
	<div class="footer">
		<p class="copyright">Copyright © 2005-2017 shopxx.net All Rights Reserved.</p>
	</div>
	<%
		if (!failed) {
	%>
	<script type="text/javascript">
		$().ready(function() {
		
			var $installStep = $("#installStep");
			var $completeStep = $("#completeStep");
			var $installMessage = $("#installMessage");
			var $installLoading = $("#installLoading");
			var $installStackTrace = $("#installStackTrace");
			var $installUrl = $("#installUrl");
			var $previous = $("#previous");
			var $complete = $("#complete");
			
			installInit();
			
			function installInit() {
				$.ajax({
					url: "install_init.jsp",
					type: "POST",
					dataType: "json",
					cache: false,
					beforeSend: function(data) {
						$installMessage.html("正在初始化数据库结构...");
					},
					success: function(data) {
						if (data.failed) {
							$installLoading.hide();
							$installMessage.html(data.message);
							$installStackTrace.html(data.stackTrace).closest("table").show();
						} else {
							installDemo();
						}
					}
				});
			}
			
			function installDemo() {
				<%
					if ("true".equals(importDemo)) {
				%>
				$.ajax({
					url: "install_demo.jsp",
					type: "POST",
					dataType: "json",
					cache: false,
					beforeSend: function(data) {
						$installMessage.html("正在初始化DEMO数据...");
					},
					success: function(data) {
						if (data.failed) {
							$installLoading.hide();
							$installMessage.html(data.message);
							$installStackTrace.html(data.stackTrace).closest("table").show();
						} else {
							installConfig();
						}
					}
				});
				<%
					} else {
				%>
				installConfig();
				<%
					}
				%>
			}
			
			function installConfig() {
				$.ajax({
					url: "install_config.jsp",
					type: "POST",
					dataType: "json",
					cache: false,
					beforeSend: function(data) {
						$installMessage.html("正在初始化系统配置...");
					},
					success: function(data) {
						if (data.failed) {
							$installLoading.hide();
							$installMessage.html(data.message);
							$installStackTrace.html(data.stackTrace).closest("table").show();
						} else {
							$installStep.removeClass("current");
							$completeStep.addClass("current");
							$installLoading.hide();
							$previous.prop("disabled", true);
							$complete.prop("disabled", false);
							$('<div class="installSuccess"><strong>恭喜您，SHOP++系统安装成功，请重新启动WEB服务器！<\/strong><span>基于安全考虑，请在安装成功后删除install目录<\/span><\/div>').replaceAll($installMessage).fadeIn(2000);
							$installUrl.fadeIn(2000);
						}
					}
				});
			}
			
			$complete.click( function() {
				alert("恭喜您，SHOP++系统安装成功，请重新启动WEB服务器！");
			});
		
		})
	</script>
	<%
		}
	%>
</body>
</html>