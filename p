import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
import csv

def scrape_data():
    # Initialize the WebDriver with Options
    options = webdriver.ChromeOptions()
    service = webdriver.chrome.service.Service(r'C:\Users\abc\Downloads\chromedriver.exe')
    driver = webdriver.Chrome(service=service, options=options)

    # Open the webpage
    driver.get('https://www.skool.com/community/-/members')  # Replace with the actual URL

    # Wait for the page to load
    time.sleep(5)  # Adjust the sleep time as needed

    # File path for saving data
    file_path = r'C:\Users\abc\Downloads\skool\members_data.csv'

    # Open the CSV file for writing
    with open(file_path, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.writer(csvfile)
        # Write the header row
        writer.writerow(['Name', 'Profile Link'])

        # Repeat the scraping process 5 times
        for _ in range(5):
            data = []

            # Find all member containers
            member_containers = driver.find_elements(By.CSS_SELECTOR, "div.styled__UserNameWrapper-sc-24o0l3-0")

            # Extract name and profile link from each member container
            for member in member_containers:
                try:
                    name = member.find_element(By.CSS_SELECTOR, "span.styled__UserNameText-sc-24o0l3-1 span").text
                    profile_link = member.find_element(By.CSS_SELECTOR, "a.styled__ChildrenLink-sc-i4j3i6-1").get_attribute("href")
                    data.append([name, profile_link])
                except Exception as e:
                    print(f"Error extracting data for a member: {e}")

            # Write the scraped data to the CSV file
            writer.writerows(data)

            # Scroll down to the bottom of the page
            driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
            
            # Wait for new content to load
            time.sleep(2)  # Adjust as needed

            # Try to click the "Next" button to go to the next page
            try:
                next_button = WebDriverWait(driver, 10).until(
                    EC.element_to_be_clickable((By.XPATH, "//*[text()='Next']"))  # Adjust the CSS selector if needed
                )
                actions = ActionChains(driver)
                actions.move_to_element(next_button).click().perform()
                
                # Wait for the next page to load
                time.sleep(5)  # Adjust the sleep time as needed
            except Exception as e:
                print(f"Error: {e}")
                break

    # Close the driver
    driver.quit()

# Run the function to scrape data
scrape_data()
