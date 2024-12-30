import requests
import json
import argparse

# replace with your web server location and login credentials
bloodhound_url = "http://localhost:8080"
username = "admin"
password = "Passw0rd123"
bearer_token = None

# put your web locations for the queries you want to import: 
customqueries = [
	"https://raw.githubusercontent.com/emiliensocchi/azurehound-queries/refs/heads/main/customqueries.json", 
	"https://raw.githubusercontent.com/hausec/Bloodhound-Custom-Queries/refs/heads/master/customqueries.json", 
	"https://raw.githubusercontent.com/ZephrFish/Bloodhound-CustomQueries/refs/heads/main/customqueries.json"
]

# because you need an authorization token
def login():
	try:
		url = bloodhound_url + "/api/v2/login"
		data = {"login_method": "secret", "username": username, "secret": password}

		response = requests.post(
			url,
			json=data,  # This will automatically set Content-Type to application/json
			headers={
				"Accept": "application/json",
				"Content-Type": "application/json",
			}
		)
		data = json.loads(response.text)
		return "Bearer " + data['data']['session_token']
	except requests.exceptions.RequestException as e:
		print(f"Error: {e}")
		return False

# to iterate the existing queries
def delete_all():
	url = bloodhound_url + "/api/v2/saved-queries"
	try:
		response = requests.get(
			url,
			headers={
				"Accept": "application/json",
				"Prefer": "0",
				"Authorization": bearer_token
			}
		)

		data = json.loads(response.text)
		for query_group in data['data']:
			if not delete_query(query_group['id']):
				print(f"Error removing query id: {id}")
				return False
			
		return True
	except requests.exceptions.RequestException as e:
		print(f"Error: {e}")
		return False

# to delete an existing query
def delete_query(id):
	url = bloodhound_url + "/api/v2/saved-queries/" + str(id)
	try:
		requests.delete(
			url,
			headers={
				"Accept": "application/json",
				"Authorization": bearer_token
			}
		)
		return True
	except requests.exceptions.RequestException as e:
		print(f"Error: {e}")
		return False

# import the query
def import_query(name, query):
	url = bloodhound_url + "/api/v2/saved-queries"
	data = { "name": name, "query": query }
	try:
		requests.post(
			url,
			json=data,  # This will automatically set Content-Type to application/json
			headers={
				"Accept": "application/json",
				"Content-Type": "application/json",
				"Authorization": bearer_token
			}
		)
		return True
	except requests.exceptions.RequestException as e:
		print(f"Error: {e}")
		return False

# for each url given, parse and send off the query for import
def main(action):

	# authenticate
	global bearer_token
	bearer_token = login()
	if not bearer_token:
		print("Error logging in. Exiting")
		exit(1)

	# delete all queries currently saved
	if action == "delete":
		if not delete_all():
			print("Error deleting queries. Exiting.")
			exit(1)
	
	# import the queries from the customqueries list
	if action == "import":
		for loc in customqueries:
			query_file = requests.get(loc)
			data = json.loads(query_file.text)
			for query_group in data['queries']:
				q_name = query_group['name']
				q_query = query_group['queryList'][0]['query']
				imported = import_query(q_name, q_query)
				if imported:
					print(f"Imported: {q_name}")
				else:
					exit(1)

if __name__ == "__main__":
	parser = argparse.ArgumentParser(description="BloodHound CE - Download and Import Custom Queries")
	parser.add_argument('--action', required=True, help='The action to perform: import or delete')
	args = parser.parse_args()
	main(args.action)
	exit(0)