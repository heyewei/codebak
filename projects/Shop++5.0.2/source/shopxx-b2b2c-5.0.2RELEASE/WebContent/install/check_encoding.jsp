<%@page language="java" contentType="text/html;charset=utf-8" pageEncoding="UTF-8"%>
<%@page import="net.shopxx.util.JsonUtils"%>
<%@include file="common.jsp"%>
<%
	String destValue = "一";
	String value = request.getParameter("value");
	if (destValue.equals(value)) {
		JsonUtils.writeValue(response.getWriter(), true);
	} else {
		JsonUtils.writeValue(response.getWriter(), false);
	}
%>