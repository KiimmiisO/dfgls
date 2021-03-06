<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="df.jsp.LabelMap"%>

<%
            //
            // Initial LabelMap
            //

            if (session.getAttribute("LANG_CODE") == null) {
                session.setAttribute("LANG_CODE", LabelMap.LANG_EN);
            }
            LabelMap labelMap = new LabelMap(session.getAttribute("LANG_CODE").toString());
            labelMap.add("TITLE_MAIN", "Message", "ข้อความ");

            request.setAttribute("labelMap", labelMap.getHashMap());

            //
            // Retrive message
            //

            String msg = session.getAttribute("MSG") == null ? labelMap.get(LabelMap.MSG_NOT_HAVE_PERMISSION) : session.getAttribute("MSG").toString();
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" type="text/css" href="../css/share.css" media="all" />
        <title>${labelMap.TITLE_MAIN}</title>
    </head>
    <body>
        <p class="msg"><%=msg%></p>
    </body>
</html>
