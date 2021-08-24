# Data Extractor using Selenium Chrome Driver

# # Faculty & Staff
# http://finance.umich.edu/treasury/mcard/discounts?field_discount_type_target_id=All&field_target_audience_target_id=29&destination=/%3Ffield_discount_type_target_id%3DAll%26field_target_audience_target_id%3D29&_exception_statuscode=404&page=0
# # Others
# http://finance.umich.edu/treasury/mcard/discounts?field_discount_type_target_id=All&field_target_audience_target_id=30&destination=/%3Ffield_discount_type_target_id%3DAll%26field_target_audience_target_id%3D30&_exception_statuscode=404&page=0
# # Students
# http://finance.umich.edu/treasury/mcard/discounts?field_discount_type_target_id=All&field_target_audience_target_id=31&destination=/%3Ffield_discount_type_target_id%3DAll%26field_target_audience_target_id%3D31&_exception_statuscode=404&page=0

# Provider
# //*[@id="block-views-block-mcard-discounts-block-1"]/div/div/div[1]/div[1]/div
# Discount
# //*[@id="block-views-block-mcard-discounts-block-1"]/div/div/div[1]/div[2]/span/a
# Discount Type
# //*[@id="block-views-block-mcard-discounts-block-1"]/div/div/div[1]/div[3]/div/a

import selenium
import selenium.webdriver
import sqlite3

def extract_data_and_populate_sql_database():
    """Perform Data Extraction on MCard Discounts page using Selenium and a headless Chrome browser."""
    faculty_staff = []
    others = []
    students = []

    # Configure Selenium to be headless
    options = selenium.webdriver.chrome.options.Options()
    options.add_argument("headless")
    driver = selenium.webdriver.Chrome(executable_path="/Users/nishantdalmia/src/eecs441/InformationRetrieval/sql/chromedriver/lib/chromedriver/chromedriver_mac", options=options)

    # An implicit wait tells WebDriver to poll the DOM for a certain amount of
    # time when trying to find any element (or elements) not immediately
    # available. Once set, the implicit wait lasts for the life of the
    # WebDriver object.
    #
    # https://selenium-python.readthedocs.io/waits.html#implicit-waits
    driver.implicitly_wait(5)

    faculty_staff_url = 'http://finance.umich.edu/treasury/mcard/discounts?field_discount_type_target_id=All&field_target_audience_target_id=29&destination=/%3Ffield_discount_type_target_id%3DAll%26field_target_audience_target_id%3D29&_exception_statuscode=404&page={}'
    others_url = 'http://finance.umich.edu/treasury/mcard/discounts?field_discount_type_target_id=All&field_target_audience_target_id=30&destination=/%3Ffield_discount_type_target_id%3DAll%26field_target_audience_target_id%3D30&_exception_statuscode=404&page={}'
    students_url = 'http://finance.umich.edu/treasury/mcard/discounts?field_discount_type_target_id=All&field_target_audience_target_id=31&destination=/%3Ffield_discount_type_target_id%3DAll%26field_target_audience_target_id%3D31&_exception_statuscode=404&page={}'

    types = [faculty_staff, others, students]
    urls = [faculty_staff_url, others_url, students_url]
    pages = [24, 15, 21]

    for category in range(3) :
        for page in range(pages[category]) :
            url = urls[category].format(page)
            driver.get(url)
            results = driver.find_elements_by_xpath('//*[@id="block-views-block-mcard-discounts-block-1"]/div/div/div')
            results_len = len(results)

            for row in range(results_len) :
                driver.get(url)

                provider_xpath = '//*[@id="block-views-block-mcard-discounts-block-1"]/div/div/div[{}]/div[1]/div'.format(row + 1)
                provider = driver.find_element_by_xpath(provider_xpath).text

                discount_xpath = '//*[@id="block-views-block-mcard-discounts-block-1"]/div/div/div[{}]/div[2]/span/a'.format(row + 1)
                discount = driver.find_element_by_xpath(discount_xpath).text

                discount_type_xpath = '//*[@id="block-views-block-mcard-discounts-block-1"]/div/div/div[{}]/div[3]/div/a'.format(row + 1)
                discount_type_len = len(driver.find_elements_by_xpath(discount_type_xpath))
                discount_type = []
                for dis_type in range(discount_type_len) :
                    discount_type_xpath = '//*[@id="block-views-block-mcard-discounts-block-1"]/div/div/div[{}]/div[3]/div/a[{}]'.format(row + 1, dis_type + 1)
                    discount_type.append(driver.find_element_by_xpath(discount_type_xpath).text)

                driver.find_element_by_xpath(discount_xpath).click()
                directions_xpath = '/html/body/div/main/div/div[6]/div/article/div/div[1]/p[1]'
                if len(driver.find_elements_by_xpath(directions_xpath)) != 0 :
                    directions = driver.find_elements_by_xpath(directions_xpath)[0].text
                else :
                    directions = " "

                next = {"Provider": provider, "Discount": discount, "Discount_Types": discount_type, "Directions": directions}
                types[category].append(next)

    # Cleanup
    driver.quit()

    # Populating DataBase.
    conn = sqlite3.connect('database.sqlite3')
    cur = conn.cursor()

    fp = open('dealtime.sql', 'r')
    cur.executescript(fp.read())
    fp.close()

    conn.commit()

    favorites = False
    count = 0
    for item in faculty_staff:
        for d_type in item["Discount_Types"]:
            cur.execute("INSERT INTO faculty_staff VALUES(?, ?, ?, ?, ?, ?)",
                        [count, item["Provider"], item["Discount"], item["Directions"], d_type, favorites])
            count += 1

    scount = 0
    for item in students:
        for d_type in item["Discount_Types"]:
            cur.execute("INSERT INTO students VALUES(?, ?, ?, ?, ?, ?)",
                        [scount, item["Provider"], item["Discount"], item["Directions"], d_type, favorites])
            scount += 1

    ocount = 0
    for item in others:
        for d_type in item["Discount_Types"]:
            cur.execute("INSERT INTO others VALUES(?, ?, ?, ?, ?, ?)",
                        [ocount, item["Provider"], item["Discount"], item["Directions"], d_type, favorites])
            ocount += 1

    conn.commit()



if __name__ == "__main__":
    extract_data_and_populate_sql_database()
