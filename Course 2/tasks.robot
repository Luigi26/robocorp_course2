*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.Excel.Files
Library             RPA.PDF
Library             RPA.HTTP
Library             RPA.Tables
Library             Collections
Library             RPA.Archive
Library             OperatingSystem


*** Variables ***
${temp_pdf_directory}=      ${OUTPUT_DIR}${/}Course 2${/}temp


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open website
    Download Excel File
    Retrieve data from Excel File
    Fill form with the saved data
    Create zip file


*** Keywords ***
Open website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    Click Button    class:btn-dark

Download Excel File
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Retrieve data from Excel File
    ${orders}=    Read table from CSV    orders.csv
    Set Test Variable    ${orders}

Fill form with the saved data
    FOR    ${order}    IN    @{orders}
        Select From List By Index    head    ${order}[Head]
        Click Element    id-body-${order}[Body]
        Input Text    css:input[class='form-control'][type='number']    ${order}[Legs]
        Input Text    address    ${order}[Address]
        Click Button    preview
        Click Button    order
        # Click Element    class:alert-danger
        ${alert-visible}=    Run Keyword And Return Status    Element Should Be Visible    class:alert-danger
        Log    ${alert-visible}
        WHILE    ${alert-visible}
            Click Button    order
            ${alert-visible}=    Run Keyword And Return Status    Element Should Be Visible    class:alert-danger
        END
        Log    ${OUTPUT_DIR}

        ${pdf}=    Store the receipt as a PDF file    ${order}[Order number]
        BREAK
        Click Button    order-another
        Click Button    class:btn-dark
    END

Store the receipt as a PDF file
    [Arguments]    ${order_number}
    ${receipt_html}=    Get Element Attribute    receipt    outerHTML
    # ${image_html}=    Get Element Attribute    robot-preview-image    outerHTML
    Screenshot    robot-preview-image    ${temp_pdf_directory}${/}screenshot.png
    Html To Pdf    ${receipt_html}    ${temp_pdf_directory}${/}${order_number}.pdf
    ${files}=    Create List    ${temp_pdf_directory}${/}screenshot.png
    Add Files To Pdf    ${files}    ${temp_pdf_directory}${/}${order_number}.pdf    append=True
    Remove File    ${temp_pdf_directory}${/}screenshot.png

Create zip file
    Archive Folder With Zip    ${temp_pdf_directory}    ${OUTPUT_DIR}${/}Course 2/receipt_archive.zip
    Remove Directory    ${temp_pdf_directory}    recursive=${True}
