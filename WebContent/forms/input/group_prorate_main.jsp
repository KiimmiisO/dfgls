<%@page contentType="text/html" pageEncoding="UTF-8" errorPage="../error.jsp"%>

<%@page import="df.jsp.Guard"%>
<%@page import="df.jsp.LabelMap"%>
<%@page import="df.jsp.Util"%>
<%@page import="df.bean.obj.util.Utils"%>
<%@page import="df.bean.db.conn.DBConnection"%>
<%@page import="df.bean.db.DBMgr"%>
<%@page import="df.bean.db.DataRecord"%>
<%@page import="df.bean.obj.util.JDate"%>
<%@page import="df.bean.process.ProcessUtil"%>
<%@page import="java.sql.*"%>

<%@ include file="../../_global.jsp" %>

<%
//
// Verify permission
//   

            if (!Guard.checkPermission(session, Guard.PAGE_INPUT_GROUP_ORDER_ITEM_CATEGORY)) {
                response.sendRedirect("../message.jsp");
                return;
            }

//
// Initial LabelMap
//

			String select_type="";

            if (session.getAttribute("LANG_CODE") == null) {
                session.setAttribute("LANG_CODE", LabelMap.LANG_EN);
            }
            LabelMap labelMap = new LabelMap(session.getAttribute("LANG_CODE").toString());
            labelMap.add("TITLE_MAIN", "Setup Prorate Doctor", "กำหนดการจ่ายค่าส่วนแบ่งแก่แพทย์");
            labelMap.add("LABEL_GROUP", "Group Code", "รหัสกลุ่ม");
			labelMap.add("LABEL_TYPE", "Type", "ประเภทการจ่ายเงิน");
            labelMap.add("LABEL_DOCTOR_CATEGORY_CODE", "Doctor Category Code", "รหัสกลุ่มแพทย์");
            labelMap.add("LABEL_DOCTOR_CODE", "Doctor Code", "รหัสแพทย์");
            labelMap.add("LABEL_DOCTOR_NAME", "Doctor Name", "คณะบุคคล");
            labelMap.add("LABEL_STATUS", "Status", "สถานะ");
            labelMap.add("LABEL_EDIT", "Edit", "แก้ไข");
           
            request.setAttribute("labelMap", labelMap.getHashMap());
            
            //
            // Process request
            //

            request.setCharacterEncoding("UTF-8");
			ProcessUtil util = new ProcessUtil();
            DataRecord groupRec = null;
            //String mm = request.getParameter("MM") != null ? request.getParameter("MM") : JDate.getMonth();
            //String yyyy = request.getParameter("YYYY") != null ? request.getParameter("YYYY") : JDate.getYear();
            //System.out.println("group="+request.getParameter("GROUP_CODE"));
            if (request.getParameter("GROUP_CODE") != null) {
            	groupRec = DBMgr.getRecord("SELECT * FROM STP_GROUP WHERE CODE = '" + request.getParameter("GROUP_CODE") + "'");
            }
			if (request.getParameter("SEL_TYPE") != null) {
				select_type=request.getParameter("SEL_TYPE");
				//out.println("select_type="+select_type);
			}
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>${labelMap.TITLE_MAIN}</title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" type="text/css" href="../../css/share.css" media="all" />

        <script type="text/javascript" src="../../javascript/ajax.js"></script>
        <script type="text/javascript" src="../../javascript/util.js"></script>
        <script type="text/javascript" src="../../javascript/search_form.js"></script>
        <script type="text/javascript" src="../../javascript/data_table.js"></script>
        <script type="text/javascript">
            
            function GROUP_CODE_KeyPress(e) {
                var key = window.event ? window.event.keyCode : e.which;    // ? IE : Firefox

                if (key == 13) {
                    document.mainForm.GROUP_CODE.blur();
                    return false;
                }
                else {
                    return true;
                }
            }

            function AJAX_Refresh_GROUP() {
                var target = "../../RetrieveData?TABLE=STP_GROUP&COND=CODE='" + document.mainForm.GROUP_CODE.value +"' AND HOSPITAL_CODE='<%=session.getAttribute("HOSPITAL_CODE")%>'";
                AJAX_Request(target, AJAX_Handle_Refresh_GROUP);
            }
            
            function AJAX_Handle_Refresh_GROUP() {
                if (AJAX_IsComplete()) {
                    var xmlDoc = AJAX.responseXML;

                    if (!isXMLNodeExist(xmlDoc, "CODE")) {
                        document.mainForm.GROUP_CODE.value = "";
                        document.mainForm.GROUP_NAME.value = "";
                        return;
                    }
                    
                    // Data found
                    document.mainForm.GROUP_NAME.value = getXMLNodeValue(xmlDoc, "GROUP_NAME_" + "<%= labelMap.getFieldLangSuffix() %>");
                }
            }           
        </script>
    </head>    
    <body>
        <form id="mainForm" name="mainForm" method="post" action="">
            <center>
                <table width="800" border="0">
                    <tr><td align="left">
                    <b><font color='#003399'><%=Utils.getInfoPage("group_prorate_main.jsp", labelMap.getFieldLangSuffix(), new DBConnection(""+session.getAttribute("HOSPITAL_CODE")))%></font></b>
                    </td></tr>
		</table>
            </center>
            <table class="form">
                <tr>
				<th colspan="4">
				  <div style="float: left;">
				  ${labelMap.TITLE_MAIN}</div>				</th>
				</tr>
                <tr>
                  <td class="label"><label for="LABEL_GROUP_CODE">${labelMap.LABEL_GROUP}</label></td>
                  <td colspan="3" class="input"><input type="text" id="GROUP_CODE" name="GROUP_CODE" class="short" value="<%= DBMgr.getRecordValue(groupRec, "CODE") %>" onkeypress="return GROUP_CODE_KeyPress(event);" onblur="AJAX_Refresh_GROUP();" />
                    <input id="SEARCH_GROUP_CODE" name="SEARCH_GROUP_CODE" type="image" class="image_button" src="../../images/search_button.png" alt="Search" onclick="groupOnSearch(); return false;" />
                    <input type="text" id="GROUP_NAME" name="GROUP_NAME" class="mediumMax" readonly="readonly" value="<%= DBMgr.getRecordValue(groupRec, "GROUP_NAME_" + labelMap.getFieldLangSuffix()) %>" /></td>
                </tr>
                <tr>
                    <td class="label"><label for="LABEL_TYPE">${labelMap.LABEL_TYPE}</label></td>
                    <td colspan="3" class="input"><select name="SEL_TYPE">
                      <option value="">SELECT TYPE</option>
                      <option value="POOL" <%= (select_type.equals("POOL") ? "selected" : "") %>>POOL</option>
                      <option value="CK" <%= (select_type.equals("CK") ? "selected" : "") %>>C.K.</option>
                    </select>
                    </td>
                </tr>
                <tr>
                    <th colspan="6" class="buttonBar">                        
                        <input type="button" id="SELECT" name="SELECT" class="button" value="${labelMap.SELECT}" onclick="window.location = 'group_prorate_main.jsp?GROUP_CODE=' + document.mainForm.GROUP_CODE.value+'&SEL_TYPE='+ document.mainForm.SEL_TYPE.value ; return false;" />
                        <input type="reset" id="RESET" name="RESET" class="button" value="${labelMap.RESET}" onclick="window.location='group_prorate_main.jsp'" />
                        <input type="button" id="CLOSE" name="CLOSE" class="button" value="${labelMap.CLOSE}" onclick="window.location='../process/ProcessFlow.jsp'" />                    </th>
                </tr>
            </table>
            <hr />
            <table class="data">
                <tr>
                    <th colspan="10" class="alignLeft">${labelMap.TITLE_DATA}</th>
                </tr>
                <tr>
                    <td class="sub_head">${labelMap.LABEL_DOCTOR_CATEGORY_CODE}</td>
                    <td class="sub_head">${labelMap.LABEL_DOCTOR_CODE}</td>
                    <td class="sub_head">${labelMap.LABEL_DOCTOR_NAME}</td>
                    <td class="sub_head">${labelMap.LABEL_TYPE}</td>
                    <td class="sub_head">${labelMap.LABEL_STATUS}</td>
                    <td class="sub_head">${labelMap.LABEL_EDIT}</td>
                    
                </tr>
                <%

            DBConnection con = new DBConnection();
            con.connectToServer();
            String sql="SELECT SD.GROUP_CODE, SD.DOCTOR_CATEGORY_CODE, SD.DOCTOR_CODE, SD.TYPE, SD.ACTIVE, DC.NAME_"+ labelMap.getFieldLangSuffix() +" AS DESCRIPTION ";
            sql+="  FROM STP_PRORATE_DOCTOR SD, DOCTOR DC ";
            sql+=" WHERE SD.DOCTOR_CODE=DC.CODE ";
            sql+=" AND SD.GROUP_CODE = '" + DBMgr.getRecordValue(groupRec, "CODE") + "' ";
            sql+=" AND SD.HOSPITAL_CODE = '" + session.getAttribute("HOSPITAL_CODE").toString() + "' ";
			if(select_type !="") 
			{
				sql+=" AND SD.TYPE='"+select_type+"'";
			}
            sql+=" ORDER BY SD.ACTIVE DESC";
            //out.println("sql="+sql);
             ResultSet rs = con.executeQuery(sql);
            
            int i = 0;
            String linkEdit;
            String activeIcon;
             while (rs.next()) {
            	
            	activeIcon = "<img src=\"../../images/" + (rs.getString("ACTIVE") != null && rs.getString("ACTIVE").equalsIgnoreCase("1") ? "" : "in") + "active_icon.png\" alt=\"" + (rs.getString("ACTIVE") != null && rs.getString("ACTIVE").equalsIgnoreCase("1") ? labelMap.get(LabelMap.ACTIVE_1) : labelMap.get(LabelMap.ACTIVE_0)) + "\" />";
            	linkEdit = "<a href=\"group_prorate_detail.jsp?GROUP_CODE="+ rs.getString("GROUP_CODE")+"&DOCTOR_CATEGORY_CODE=" + rs.getString("DOCTOR_CATEGORY_CODE")+"&SEL_TYPE=" + rs.getString("TYPE") + "&DOCTOR_CODE=" + rs.getString("DOCTOR_CODE")+"\" title=\"" + labelMap.get(LabelMap.EDIT) + "\"><img src=\"../../images/edit_button.png\" alt=\"" + labelMap.get(LabelMap.EDIT) + "\" /></a>";
                 %>                
                <tr>
                    <td class="row<%=i % 2%>"><%= Util.formatHTMLString(rs.getString("DOCTOR_CATEGORY_CODE"), true)%></td>
                    <td class="row<%=i % 2%>"><%= Util.formatHTMLString(rs.getString("DOCTOR_CODE"), true)%></td>
                    <td class="row<%=i % 2%> "><%= Util.formatHTMLString(rs.getString("DESCRIPTION"), true)%></td>
                    <td class="row<%=i % 2%> "><%= Util.formatHTMLString(rs.getString("TYPE"), true)%></td>
                    <td class="row<%=i % 2%> alignCenter"><%= activeIcon %></td>
                    <td class="row<%=i % 2%> alignCenter"><%= linkEdit%></td>
                </tr>
                <%
                i++;
            }
            if (rs != null) {
                rs.close();
            }
            con.freeConnection();
                %>                
                <tr>
                    <th colspan="10" class="buttonBar">
                        <input type="button" id="NEW" name="NEW" class="button" value="${labelMap.NEW}" onclick="window.location = 'group_prorate_detail.jsp?GROUP_CODE=' + document.mainForm.GROUP_CODE.value+'&SEL_TYPE='+ document.mainForm.SEL_TYPE.value;" />
                    </th>
                </tr>
            </table>
        </form>
    </body>
</html>
<script language="javascript">
	function groupOnSearch(){
		//var y = document.getElementById('YYYY');
		//var m = document.getElementById('MM');
		openSearchForm('../search.jsp?TABLE=STP_GROUP&DISPLAY_FIELD=GROUP_NAME_<%= labelMap.getFieldLangSuffix() %>&TARGET=GROUP_CODE&BEINSIDEHOSPITAL=1&BEACTIVE=1&HANDLE=AJAX_Refresh_GROUP');	
	}
</script>

