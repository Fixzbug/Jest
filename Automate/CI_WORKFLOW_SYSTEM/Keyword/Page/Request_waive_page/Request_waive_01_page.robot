*** Settings ***
Resource    ${CURDIR}/../../../Import/Path_import.robot    # robotcode: ignore

*** Variables ***

# group data all
${group_data}
${keys_group_data}
${result_excel} 
${nextcase}

# request no
${result_request_no}

# write data
${Rows}
${point}
${count}

# date
${date_start_cal_date}
${date_paid_date}

*** Keywords ***

SET FORMAT DATA TYPE 01 - WRITE
    [Arguments]    ${row}    ${start_at_case}    ${end_at_case}
    ${countrow}    BuiltIn.Set Variable If    ${end_at_case} <= ${data_count_row}    ${end_at_case}    ${data_count_row}
    
    FOR  ${index}  IN RANGE    ${start_at_case}    ${countrow} + 1 

        ${result_excel}    JSONLibrary.Get Value From Json    ${data_from_excel_by_sheet}    $[?(@.TC == '${row}_${index}')]
        ${group_data}    BuiltIn.Set Variable   ${result_excel}[0]
        BuiltIn.Set Global Variable    ${group_data}

        ${Request_No}    BuiltIn.Set Variable    '${group_data}[${keys_group_data_label}[8]]'    #'${group_data}[Request No.]'     # get case   สำหรับเช็ค  
        ${State}    BuiltIn.Set Variable    '${group_data}[${keys_group_data_label}[9]]'         #'${group_data}[State]'           # get case   สำหรับเช็ค 
            
        IF  ${Request_No} == 'none' and ${State} == 'none'             # none, none -> make
                                
            ${Rows}    BuiltIn.Evaluate    ${index} + 2                # +2 because add title at row 2 
            BuiltIn.Set Global Variable    ${Rows}   
            BuiltIn.Log    ----------------------------------------    WARN 
            BuiltIn.Log    CONATRACT->ROW->${Rows}:${row}_${index}    WARN
            BuiltIn.Log    ----------------------------------------    WARN

            # input Contract no, ID card, business click aprrove
            Request_waive_01_feature.SET FEATURE - TYPE - 01 - INPUT CRITERIA SEARCH - REQUEST TYPE - PAGE REQUEST WAIVE
    
            ${status_error}    BuiltIn.Run Keyword And Return Status    Common_keyword.WAITING ELEMENT WHEN ELEMENT IS VISIBLE BY LOCATOR    ${txt_error}    5s
            IF  '${status_error}' == 'True'
                ${error_msg}    SeleniumLibrary.Get Text    ${txt_error}    
                ${nextcase}    BuiltIn.Set Variable    False
                BuiltIn.Set Global Variable    ${nextcase}   
                Common_feature.SET - DATA TO EXCEL    ${Excel_name}    ${type_01}    ${Rows}    9    FAIL  
                Common_feature.SET - DATA TO EXCEL    ${Excel_name}    ${type_01}    ${Rows}    10    FAIL  
                BuiltIn.fail    !!!!!!!!!!!!! ${error_msg} !!!!!!!!!!!!!  
                Common_keyword.CLOSE ALL BROWSERS TEARDOWN
            ELSE
              
                # get data from web before run
                ${value_customer_name}    Common_keyword.GET VALUE PAGE CONTAINS ELEMENT BY LOCATOR AND STRIP AND NOT CHECK EQUAL AND RETURN    ${txt_customer_name}
                ${value_total_os_balance}    Common_keyword.GET VALUE PAGE CONTAINS ELEMENT BY LOCATOR AND STRIP AND NOT CHECK EQUAL AND RETURN    ${txt_total_os_balance}
      
                IF  '${value_customer_name}' != 'none' and '${value_total_os_balance}' != 'none'
                    Common_feature.SET - DATA TO EXCEL    ${Excel_name}    ${type_01}    ${Rows}    11    ${value_customer_name}  
                    Common_feature.SET - DATA TO EXCEL    ${Excel_name}    ${type_01}    ${Rows}    13    ${value_total_os_balance}    
                    Common_feature.SET - DATA TO EXCEL    ${Excel_name}    ${type_01}    ${Rows}    32    ${value_customer_name}
                    Common_feature.SET - DATA TO EXCEL    ${Excel_name}    ${type_01}    ${Rows}    16    ${group_user}[${keys_group_user}[3]]    #P2503064  
                    Common_feature.SET - DATA TO EXCEL    ${Excel_name}    ${type_01}    ${Rows}    29    ${group_user}[${keys_group_user}[3]]    #P2503064  
                    Common_feature.SET - DATA TO EXCEL    ${Excel_name}    ${type_01}    ${Rows}    33    ${group_user}[${keys_group_user}[3]]    #P2503064
                    ${nextcase}    BuiltIn.Set Variable    True
                    BuiltIn.Set Global Variable    ${nextcase}
                ELSE
                    ${nextcase}    BuiltIn.Set Variable    False
                    BuiltIn.Set Global Variable    ${nextcase}
                    Common_feature.SET - DATA TO EXCEL    ${Excel_name}    ${type_01}    ${Rows}    9    FAIL  
                    Common_feature.SET - DATA TO EXCEL    ${Excel_name}    ${type_01}    ${Rows}    10    FAIL  
                    BuiltIn.fail    !!!!!!!!!!!!! error some get value !!!!!!!!!!!!! 
                    Common_keyword.CLOSE ALL BROWSERS TEARDOWN 
                END  
            END

            BuiltIn.Exit For Loop
            
        END
              
    END

SET FORMAT DATA TYPE 01 - USING
    [Arguments]    ${row}    ${start_at_case}    ${end_at_case}    ${user_level}
    ${countrow}    BuiltIn.Set Variable If    ${end_at_case} <= ${data_count_row}    ${end_at_case}    ${data_count_row}
    
    ${count}    BuiltIn.Evaluate    0    # set count error start at zero
    BuiltIn.Set Global Variable    ${count} 

    FOR  ${index}  IN RANGE    ${start_at_case}    ${countrow} + 1 
        ${result_excel}    JSONLibrary.Get Value From Json    ${data_from_excel_by_sheet}    $[?(@.TC == '${row}_${index}')]
        ${group_data}    BuiltIn.Set Variable   ${result_excel}[0]
        BuiltIn.Set Global Variable    ${group_data}

        ${Request_No}    BuiltIn.Set Variable    '${group_data}[${keys_group_data_label}[8]]'    #'${group_data}[Request No.]'     # get case   สำหรับเช็ค  
        ${State}    BuiltIn.Set Variable    '${group_data}[${keys_group_data_label}[9]]'         #'${group_data}[State]'           # get case   สำหรับเช็ค 
            
        IF  '${DBUG}' == 'TRUE'
                BuiltIn.Log    ${result_excel}    WARN
        ELSE

            IF  '${point}' == '0'    # case point = 0 mean error and counter fail 1 time just Break
                BuiltIn.Exit For Loop
            ELSE IF  '${point}' == '1' and '${count}' == '1'    # case point = 1 mean pass and counter fix 1 time just Break
                BuiltIn.Exit For Loop
            END

            IF  ${Request_No} == 'none' and ${State} == 'none' and '${count}' <= '3'             # none, none -> make
                                    
                ${Rows}    BuiltIn.Evaluate    ${index} + 2                                      # +2 because add title at row 2 
                BuiltIn.Set Global Variable    ${Rows}   
                BuiltIn.Log    ----------------------------------------    WARN 
                BuiltIn.Log    CONATRACT->ROW->${Rows}:${row}_${index}    WARN
                BuiltIn.Log    ----------------------------------------    WARN

                # input Contract no, ID card, business click aprrove
                Request_waive_01_feature.SET FEATURE - TYPE - 01 - INPUT CRITERIA SEARCH - REQUEST TYPE - PAGE REQUEST WAIVE

                Common_keyword.WAITING ELEMENT WHEN ELEMENT IS VISIBLE BY LOCATOR    ${txt_ib_request_date}    50s
                ${request_date}    SeleniumLibrary.Get Value    ${txt_ib_request_date}
                BuiltIn.Log    >Request Date From Web>${request_date}    WARN

                ${date_current}    Common_keyword.GET DATE IN FORMATTED DATE TIME

                IF  '${request_date}' == '${date_current}'
                    # ถ้าวันที่ ปัจุบันบนเครื่อง jenkins ตรงกับ request date ให้เอาวันที่ ${date_current} ไปเล่น
                    ${date_start_cal_date}    BuiltIn.Set Variable    ${date_current}
                    BuiltIn.Set Global Variable    ${date_start_cal_date}    

                    # ${date_paid_date}    Common_keyword.GET DATE IN FORMATTED DATE TIME PLUS    # + 1 สำหรับเล่นวันถัดไป
                    # BuiltIn.Set Global Variable    ${date_paid_date}    

                    ${date_paid_date}    BuiltIn.Set Variable    ${date_current}    # ใช้วันปัจุบันบนเครื่องเลย
                    BuiltIn.Set Global Variable    ${date_paid_date}

                ELSE IF  '${request_date}' != '${date_current}'
                    # ถ้าวันที่ ปัจุบันบนเครื่อง jenkins ไม่ตรงกับ request date ให้เอาวันที่ ${request_date} ไปเล่น
                    ${date_start_cal_date}    BuiltIn.Set Variable    ${request_date}
                    BuiltIn.Set Global Variable    ${date_start_cal_date}    

                    # ${date_paid_date}    Common_keyword.CONVERT GET DATE IN FORMATTED DATE TIME PLUS    ${request_date}     # + 1 สำหรับเล่นวันถัดไป
                    # BuiltIn.Set Global Variable    ${date_paid_date} 

                    ${date_paid_date}    BuiltIn.Set Variable    ${request_date}    # ใช้วันปัจุบันบนเว็บเลย
                    BuiltIn.Set Global Variable    ${date_paid_date}

                ELSE
                    BuiltIn.fail    !!!!!!!!!!!!! ERROR DATE !!!!!!!!!!!!!  
                END

                # verify lable
                Request_waive_01_feature.SET FEATURE - TYPE - 01 - VERIFY - REQUEST PAGE - PAGE REQUEST WAIVE    
    
                # verify data
                Request_waive_01_feature.SET FEATURE - TYPE - 01 - VERIFY - DATA REQUEST PAGE - PAGE REQUEST WAIVE     

                # กรอก receipt no
                Request_waive_01_feature.SET FEATURE - TYPE - 01 - INPUT CRITERIA SEARCH - RECEIPT NO - PAGE REQUEST WAIVE

                # verify data
                Request_waive_01_feature.SET FEATURE - TYPE - 01 - VERIFY - DATA REQUEST PAGE - TOTAL PENALTY - PAGE REQUEST WAIVE

                # กรอก waive amount
                Request_waive_01_feature.SET FEATURE - TYPE - 01 - INPUT CRITERIA SEARCH - WAIVE AMOUNT - PAGE REQUEST WAIVE

                # เลือก reason
                Request_waive_01_feature.SET FEATURE - TYPE - 01 - INPUT CRITERIA SEARCH - REASON - PAGE REQUEST WAIVE

                # กรอก reason note
                Request_waive_01_feature.SET FEATURE - TYPE - 01 - INPUT CRITERIA SEARCH - REASON NOTE - PAGE REQUEST WAIVE

                # verify title -> send to , note ,  input send to , note 
                Request_waive_01_feature.SET FEATURE - TYPE - 01 - VERIFY - SEND TO - PAGE REQUEST WAIVE    user_level=1   # Send to User_1 = P2510033

                # verify note
                Request_waive_01_feature.SET FEATURE - TYPE - 01 - VERIFY - NOTE - PAGE REQUEST WAIVE

                # input data note
                Request_waive_01_feature.SET FEATURE - TYPE - 01 - INPUT - NOTE - PAGE REQUEST WAIVE

                # กด approve
                Request_waive_01_feature.SET FEATURE - TYPE - 01 - CLICK - APPROVE - PAGE REQUEST WAIVE    

                # verify pop up
                Request_waive_01_feature.SET FEATURE - TYPE - 01 - VERIFY - APPROVE POPUP - PAGE REQUEST WAIVE    

                # verify pop up
                Request_waive_01_feature.SET FEATURE - TYPE - 01 - CLICK - APPROVE POPUP - CLICK OK - PAGE REQUEST WAIVE   

                # get data at current page request no
                Request_waive_01_feature.SET FEATURE - TYPE - 01 - SAVE DATA - REQUSET NO - PAGE REQUEST WAIVE  

                # wait for check excel write
                Request_waive_01_feature.SET FEATURE - TYPE - 01 - SAVE DATA TO EXCEL - BY STATE 
                
            END
        END
    END

                
# add new
PAGE REQUEST WAIVE - TYPE 01 - OPEN INRANET
    IF  '${nextcase}' == 'True'
        Common_keyword.OPEN INTRANET
        Common_keyword.CLICK SSO ICON
    END

# add new
PAGE REQUEST WAIVE - TYPE 01 - INPUT USENAME AND PASSWORD BY USER LEVEL
    [Arguments]    ${user_level}

    IF  '${user_level}' == '0'         # user approve user0 
        PAGE REQUEST WAIVE - TYPE 01 - SETTING LOGIN    WORKFLOW    ${group_user}[${keys_group_user}[3]]    ${group_user}[${keys_group_user}[4]]    ${user_level}    # 1 row,col -> 3,4 -> P2503064
    ELSE IF  '${user_level}' == '1'    # user approve user1 
        PAGE REQUEST WAIVE - TYPE 01 - SETTING LOGIN    WORKFLOW    ${group_user}[${keys_group_user}[5]]    ${group_user}[${keys_group_user}[6]]    ${user_level}    # 1 row,col -> 5,6 -> P2510033
    ELSE IF  '${user_level}' == '2'    # user approve user2
        PAGE REQUEST WAIVE - TYPE 01 - SETTING LOGIN    WORKFLOW    ${group_user}[${keys_group_user}[7]]    ${group_user}[${keys_group_user}[8]]    ${user_level}     # 2 row,col -> 7,8  -> P2503067
    ELSE IF  '${user_level}' == '3'    # user approve user3
        PAGE REQUEST WAIVE - TYPE 01 - SETTING LOGIN    WORKFLOW    ${group_user}[${keys_group_user}[9]]    ${group_user}[${keys_group_user}[10]]    ${user_level}     # 3 row,col -> 9,10 -> P2106010 
    ELSE IF  '${user_level}' == '4'    # user approve user4
        PAGE REQUEST WAIVE - TYPE 01 - SETTING LOGIN    WORKFLOW    ${group_user}[${keys_group_user}[11]]    ${group_user}[${keys_group_user}[12]]    ${user_level}     # 4 row,col -> 11,12 -> KIMURA
    END

# add new
PAGE REQUEST WAIVE - TYPE 01 - SETTING LOGIN
    [Arguments]    ${system_name}    ${username}    ${password}    ${user_level}

    [Timeout]    180s
        # หน้า login #User Authentication
        #Verify
        SeleniumLibrary.Wait Until Element Is Visible    ${verify_header_locator}    timeout=60s    # User Authentication
        
        # Username
        SeleniumLibrary.Wait Until Element Is Visible    ${sso_username_text_area}
        SeleniumLibrary.Input Text    ${sso_username_text_area}   ${username}
        # Password
        SeleniumLibrary.Wait Until Element Is Visible    ${SSO_Password_text_area}
        SeleniumLibrary.Input Password    ${sso_password_text_area}    ${password}  
            
        # Click login button
        Capture_Screen.CUSTOM CAPTURE WITH SYSTEM AND CASE    ${system_name}    LOGIN - USER LEVEL - ${user_level} USER - ${username}
        SeleniumLibrary.Wait Until Element Is Visible    ${btn_login_on_user_authentication}
        SeleniumLibrary.Click Button    ${btn_login_on_user_authentication}


PAGE REQUEST WAIVE - TYPE 01 - [CLICK] - LINK 
    ${link_system}=    Common_keyword.REPLACE BY DATA EXCEL AND RETURN LOCATOR DATA GRID    ${link_system}    ${group_user}[${keys_group_user}[2]]   
    Common_keyword.WAITING ELEMENT WHEN ELEMENT IS VISIBLE BY LOCATOR    ${link_system}     
    Common_keyword.CLICK ELEMENT BY LOCATOR    ${link_system}   

# wait update page 
PAGE REQUEST WAIVE - TYPE 01 - [WAIT] - [VERIFY] PAGE
    Common_keyword.WAITING FOR DATA UPDATE    1s    

PAGE REQUEST WAIVE - TYPE 01 - [CLICK] - [MENU]
    [Arguments]    ${menu} 
    ${locator_menu}    Common_keyword.REPLACE BY DATA EXCEL AND RETURN LOCATOR DATA GRID    ${menu_locator}    ${menu}
    Common_keyword.CLICK ELEMENT WHEN ELEMENT IS VISIBLE    ${locator_menu}

PAGE REQUEST WAIVE - TYPE 01 - [CLICK] - [SUB MENU]
    [Arguments]    ${sub_menu} 
    ${locator_menu}    Common_keyword.REPLACE BY DATA EXCEL AND RETURN LOCATOR DATA GRID    ${sub_menu_locator}    ${sub_menu}
    Common_keyword.CLICK ELEMENT WHEN ELEMENT IS VISIBLE    ${locator_menu}

# เลือก iframe
PAGE REQUEST WAIVE - TYPE 01 - [SELCET] - [FRAME] IFRAME
    Common_keyword.SELECT IFRAME    ${iframe_locator}

# เลือก iframe
PAGE REQUEST WAIVE - TYPE 01 - [UNSELCET] - [FRAME] UNIFRAME
    Common_keyword.UNSELECT IFRAME   

# เลือก request type
PAGE REQUEST WAIVE - TYPE 01 - [SELCET] - [DROPDOWN] REQUEST TYPE
    Common_keyword.SELECT OPTION SELECT FROM LIST BY LABEL    ${sel_request_type_locator}    ${group_user}[${keys_group_user}[1]]
    
PAGE REQUEST WAIVE - TYPE 01 - [CLICK] - [BTN] APPROVE
    Common_keyword.CLICK ELEMENT WHEN ELEMENT IS VISIBLE    ${btn_approve}    

#verify   
PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [LABEL] BUSINESS
    Common_keyword.WAITING ELEMENT WHEN ELEMENT IS VISIBLE BY LOCATOR    ${lbl_req_business}    5s          

PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [LABEL] CONTRACT NO 
    Common_keyword.WAITING ELEMENT WHEN ELEMENT IS VISIBLE BY LOCATOR    ${lbl_contract_no}    5s          

PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [LABEL] ID CARD 
    Common_keyword.WAITING ELEMENT WHEN ELEMENT IS VISIBLE BY LOCATOR    ${lbl_id_card}    5s       

# input 
PAGE REQUEST WAIVE - TYPE 01 - [INPUT] - [TEXT] ID CARD 
    Common_keyword.INPUT TEXT WHEN ELEMENT IS VISIBLE    ${req_id_card}    ${group_data}[${keys_group_data_label}[2]]     

PAGE REQUEST WAIVE - TYPE 01 - [SELECT] - [DROPDOWN] BUSINESS
    Common_keyword.SELECT OPTION SELECT FROM LIST BY LABEL    ${sel_req_business}    ${group_data}[${keys_group_data_label}[3]]   
  
PAGE REQUEST WAIVE - TYPE 01 - [INPUT] - [TEXT] CONTRACT NO  
    Common_keyword.INPUT TEXT WHEN ELEMENT IS VISIBLE    ${req_contract_no}    ${group_data}[${keys_group_data_label}[4]]    
  
#verify 
PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [LABELS] REQUEST TYPE
    Common_keyword.GET TEXT PAGE CONTAINS ELEMENT BY LOCATOR    ${lbl_request_type}    ${group_data_label}[${keys_group_data_label}[1]]   
    
PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [LABELS] CUSTOMER ID
    Common_keyword.GET TEXT PAGE CONTAINS ELEMENT BY LOCATOR    ${lbl_customer_id}    ${group_data_label}[${keys_group_data_label}[2]]
    
PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [LABELS] CUSTOMER NAME
    Common_keyword.GET TEXT PAGE CONTAINS ELEMENT BY LOCATOR    ${lbl_customer_name}    ${group_data_label}[${keys_group_data_label}[10]]
    
PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [LABELS] BUSINESS
    Common_keyword.GET TEXT PAGE CONTAINS ELEMENT BY LOCATOR    ${lbl_business}    ${group_data_label}[${keys_group_data_label}[3]]
    
PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [LABELS] CONTRACT NO
    Common_keyword.GET TEXT PAGE CONTAINS ELEMENT BY LOCATOR    ${lbl_contract_no}    ${group_data_label}[${keys_group_data_label}[4]]
    
PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [LABELS] REQUEST DATE
    Common_keyword.GET TEXT PAGE CONTAINS ELEMENT BY LOCATOR    ${lbl_request_date}    ${group_data_label}[${keys_group_data_label}[16]]
    
PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [LABELS] REQUESTER
    Common_keyword.GET TEXT PAGE CONTAINS ELEMENT BY LOCATOR    ${lbl_requester}    ${group_data_label}[${keys_group_data_label}[15]]
    
PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [LABELS] TEAM
    Common_keyword.GET TEXT PAGE CONTAINS ELEMENT BY LOCATOR    ${lbl_team}    ${group_data_label}[${keys_group_data_label}[17]]
    
PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [LABELS] OD STATUS
    Common_keyword.GET TEXT PAGE CONTAINS ELEMENT BY LOCATOR    ${lbl_od_status}    ${group_data_label}[${keys_group_data_label}[11]]

PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [LABELS] TOTAL O/S BALANCE
    Common_keyword.GET TEXT PAGE CONTAINS ELEMENT BY LOCATOR    ${lbl_total_os_balance}    ${group_data_label}[${keys_group_data_label}[12]]

PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [LABELS] TOTAL PENALTY
    Common_keyword.GET TEXT PAGE CONTAINS ELEMENT BY LOCATOR    ${lbl_total_penalty}    ${group_data_label}[${keys_group_data_label}[13]]

# verify loading
PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [LOADING] 
    Common_keyword.WAITING ELEMENT WHEN ELEMENT IS VISIBLE BY LOCATOR    ${loading}    time_out=10s

#verify data
PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [DATA] REQUEST TYPE
    Common_keyword.GET TEXT PAGE CONTAINS ELEMENT BY LOCATOR OPTIPON REPLACE AND EQUAL STRINGS    ${txt_all_replace}    ${group_data}[${keys_group_data_label}[1]]
      
PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [DATA] CUSTOMER ID
    Common_keyword.GET VALUE PAGE CONTAINS ELEMENT BY LOCATOR AND EQUAL STRINGS   ${txt_customer_id}    ${group_data}[${keys_group_data_label}[2]]    

PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [DATA] BUSINESS   
    Common_keyword.GET TEXT PAGE CONTAINS ELEMENT BY LOCATOR OPTIPON REPLACE AND EQUAL STRINGS    ${txt_all_replace}    ${group_data}[${keys_group_data_label}[3]]
    
PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [DATA] CONTRACT NO
    Common_keyword.GET VALUE PAGE CONTAINS ELEMENT BY LOCATOR AND EQUAL STRINGS    ${txt_contract_no}    ${group_data}[${keys_group_data_label}[4]]    
    
PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [DATA] CUSTOMER NAME
    Common_keyword.GET VALUE PAGE CONTAINS ELEMENT BY LOCATOR AND EQUAL STRINGS    ${txt_customer_name}    ${group_data}[${keys_group_data_label}[10]]    
     
PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [DATA] OD STATUS
    Common_keyword.GET VALUE PAGE CONTAINS ELEMENT BY LOCATOR AND EQUAL STRINGS    ${txt_od_status}    ${group_data}[${keys_group_data_label}[11]]    

PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [DATA] REQUEST DATE
    Common_keyword.GET VALUE PAGE CONTAINS ELEMENT BY LOCATOR AND EQUAL STRINGS    ${txt_request_date}    ${date_start_cal_date}    
    
PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [DATA] REQUESTER
    Common_keyword.GET VALUE PAGE CONTAINS ELEMENT BY LOCATOR AND EQUAL STRINGS    ${txt_requester}    ${group_data}[${keys_group_data_label}[15]]    
    
PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [DATA] TEAM
    Common_keyword.GET VALUE PAGE CONTAINS ELEMENT BY LOCATOR AND EQUAL STRINGS    ${txt_team}    ${group_data}[${keys_group_data_label}[17]]    
    

#verify
PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [DATA] TOTAL O/S BALANCE
    Common_keyword.GET VALUE PAGE CONTAINS ELEMENT BY LOCATOR AND EQUAL STRINGS    ${txt_total_os_balance}    ${group_data}[${keys_group_data_label}[12]]    

PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [DATA] TOTAL PENALTY
    Common_keyword.GET VALUE PAGE CONTAINS ELEMENT BY LOCATOR AND EQUAL STRINGS    ${txt_total_penalty}    ${group_data}[${keys_group_data_label}[13]]    

#verify   
PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [LABEL] RECEIPT NO
    Common_keyword.WAITING ELEMENT WHEN ELEMENT IS VISIBLE BY LOCATOR    ${lbl_receipt_no}       

# input 
PAGE REQUEST WAIVE - TYPE 01 - [INPUT] - [TEXT] RECEIPT NO
    Common_keyword.INPUT TEXT WHEN ELEMENT IS VISIBLE    ${req_receipt_no}    ${group_data}[${keys_group_data_label}[5]]   

# button 
PAGE REQUEST WAIVE - TYPE 01 - [CLICK] - [BTN] RECEIPT NO ADD
    Common_keyword.CLICK ELEMENT WHEN ELEMENT IS VISIBLE    ${btn_receipt_add}

# veify
PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [TABLE] RECEIPT NO TABLE
    ${receipt_status}    BuiltIn.Run Keyword And Return Status    Common_keyword.WAITING ELEMENT WHEN ELEMENT IS VISIBLE BY LOCATOR    ${table_receipt}    5s
    IF  '${receipt_status}' == 'False'
        BuiltIn.Fail    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! DATA FAIL RECEIPT NO DONT HAVE IN SYSTEM !!!!!!!!!!!!!!!!!!!!!!!!! 
        Common_keyword.CLOSE ALL BROWSERS TEARDOWN
        ${nextcase}    BuiltIn.Set Variable    False
        BuiltIn.Set Global Variable    ${nextcase}
    ELSE
        ${nextcase}    BuiltIn.Set Variable    True
        BuiltIn.Set Global Variable    ${nextcase}
    END
        

# verify   
PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [LABEL] WAIVE AMOUNT
    Common_keyword.WAITING ELEMENT WHEN ELEMENT IS VISIBLE BY LOCATOR    ${lbl_req_waive_amount}       

# input 
PAGE REQUEST WAIVE - TYPE 01 - [INPUT] - [TEXT] WAIVE AMOUNT
    Common_keyword.INPUT TEXT WHEN ELEMENT IS VISIBLE    ${req_waive_amount}    ${group_data}[${keys_group_data_label}[14]]   

#verify   
PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [LABEL] REASON
    Common_keyword.WAITING ELEMENT WHEN ELEMENT IS VISIBLE BY LOCATOR    ${lbl_req_reason}       

# input 
PAGE REQUEST WAIVE - TYPE 01 - [SELECT] - [SELECT] REASON
    Common_keyword.SELECT OPTION SELECT FROM LIST BY LABEL    ${sel_req_reason}    ${group_data}[${keys_group_data_label}[18]]  

#verify   
PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [LABEL] REASON NOTE
    Common_keyword.WAITING ELEMENT WHEN ELEMENT IS VISIBLE BY LOCATOR    ${lbl_req_reason_note}       

# input 
PAGE REQUEST WAIVE - TYPE 01 - [INPUT] - [TEXT] REASON NOTE
    Common_keyword.INPUT TEXT WHEN ELEMENT IS VISIBLE    ${req_reason_note}    ${group_data}[${keys_group_data_label}[19]]   

# verify   
PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [LABEL] SEND TO
    [Arguments]    ${user_level}
    ${status}    BuiltIn.Run Keyword And Return Status    Common_keyword.WAITING ELEMENT WHEN ELEMENT IS VISIBLE BY LOCATOR    ${lbl_req_send_to}    10s
    IF  '${status}' == 'True'
        IF  '${user_level}' == '0'
            Common_keyword.SELECT OPTION SELECT FROM LIST BY LABEL    ${sel_req_send_to}    ${group_user}[${keys_group_user}[3]]    # Send to 1 = P2503064
        ELSE IF  '${user_level}' == '1'
            Common_keyword.SELECT OPTION SELECT FROM LIST BY LABEL    ${sel_req_send_to}    ${group_user}[${keys_group_user}[5]]    # Send to 2 = P2510033 
        ELSE IF  '${user_level}' == '3'
            Common_keyword.SELECT OPTION SELECT FROM LIST BY LABEL    ${sel_req_send_to}    ${group_user}[${keys_group_user}[7]]    # Send to 3 = P2503067 
        ELSE IF  '${user_level}' == '4'
            Common_keyword.SELECT OPTION SELECT FROM LIST BY LABEL    ${sel_req_send_to}    ${group_user}[${keys_group_user}[9]]    # Send to 4 = P2106010 
        ELSE IF  '${user_level}' == '5'
            Common_keyword.SELECT OPTION SELECT FROM LIST BY LABEL    ${sel_req_send_to}    ${group_user}[${keys_group_user}[11]]    # Send to 5 = KIMURA 
        END
    ELSE
        BuiltIn.Log    NO USER MATCH SENDTO    WARN
    END


# verify   
PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [LABEL] NOTE
    Common_keyword.WAITING ELEMENT WHEN ELEMENT IS VISIBLE BY LOCATOR    ${lbl_req_note}       

# input 
PAGE REQUEST WAIVE - TYPE 01 - [INPUT] - [TEXT] NOTE
    Common_keyword.INPUT TEXT WHEN ELEMENT IS VISIBLE    ${req_note}    ${group_data}[${keys_group_data_label}[20]]   
    

# verify title popup
PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [TITLE] APPROVE 
    Common_keyword.WAITING ELEMENT WHEN ELEMENT IS VISIBLE BY LOCATOR     ${verfiy_approve_popup}    

PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [POPUP] APPROVE - [CLICK] OK
    Common_keyword.CLICK ELEMENT WHEN ELEMENT IS VISIBLE     ${btn_ok_approve_popup}    

PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [POPUP] APPROVE - [CLICK] CANCEL
    Common_keyword.CLICK ELEMENT WHEN ELEMENT IS VISIBLE     ${btn_cancel_approve_popup}    


# get requst no save to excel
PAGE REQUEST WAIVE - TYPE 01 - [GET] - [DATA] REQUEST NO - [SAVE] EXCEL
    
    # wait finish loading..
    PAGE REQUEST WAIVE - TYPE 01 - [VERIFY] - [LOADING]

    ${state}    Common_keyword.RUN KEYWORD AND IGNORE ERROR WAITING ELEMENT WHEN ELEMENT IS VISIBLE BY LOCATOR     ${table_manager_locator}    60s    # set up time
    BuiltIn.Log    STATE SAVE->${state}    WARN

    IF  '${state}' == 'True'    # ถ้าเจอ
        ${point}    BuiltIn.Evaluate    1
        BuiltIn.Set Global Variable    ${point}
        Common_keyword.WAITING ELEMENT WHEN ELEMENT IS VISIBLE BY LOCATOR    ${title_system_cancel_req_locator}    5s        # makesure title is true
        Common_keyword.WAITING ELEMENT WHEN ELEMENT IS VISIBLE BY LOCATOR    ${txt_request_no}    5s                         # get req No to save
        ${result_request_no}    Common_keyword.GET VALUE PAGE CONTAINS ELEMENT BY LOCATOR AND STRIP AND NOT CHECK EQUAL AND RETURN    ${txt_request_no}
        BuiltIn.Log    REQ_NO_SAVE->${result_request_no}    WARN
        BuiltIn.Set Global Variable    ${result_request_no}

    ELSE IF  '${state}' == 'False'    # ถ้าไม่เจอ
        ${point}    BuiltIn.Evaluate    0
        BuiltIn.Set Global Variable    ${point}
        Common_keyword.WAITING ELEMENT WHEN ELEMENT IS VISIBLE BY LOCATOR    ${title_system_req_locator}    5s               # verify table before title -> Request
        Common_keyword.WAITING ELEMENT WHEN ELEMENT IS VISIBLE BY LOCATOR    ${txt_error}    5s 
        ${msgerror}    Common_keyword.GET TEXT PAGE CONTAINS ELEMENT BY LOCATOR NO SPLIT    ${txt_error}  
        BuiltIn.Log    MSG ERROR->${msgerror}    WARN
        ${result_request_no}    BuiltIn.Set Variable    ${msgerror}    
        BuiltIn.Set Global Variable    ${result_request_no}

    END

# wait for check excel write
PAGE REQUEST WAIVE - TYPE 01 - [WAIT] - WAIT MAKE REMARK NOTE
    Common_keyword.WAITING ELEMENT WHEN ELEMENT IS VISIBLE BY LOCATOR    ${txt_request_no}    10s    # get req No to save
    Common_keyword.INPUT TEXT WHEN ELEMENT IS VISIBLE    ${req_note}    ${group_data}[${keys_group_data_label}[20]] 

# btn back 
PAGE REQUEST WAIVE - TYPE 01 - [CLICK] - [BTN] BACK
    Common_keyword.CLICK ELEMENT WHEN ELEMENT IS VISIBLE     ${btn_back}    10s

# logout
PAGE REQUEST WAIVE - TYPE 01 - [CLICK] - [BTN] LOGOUT
    Common_keyword.CLICK ELEMENT WHEN ELEMENT IS VISIBLE     ${btn_signout}    10s    

