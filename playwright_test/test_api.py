import asyncio
from playwright.async_api import async_playwright, Playwright

async def run(playwright: Playwright):
    #first call to the api
    context = await playwright.request.new_context()
    response1 = await context.post("https://l7241ivbyh.execute-api.us-east-1.amazonaws.com/development/subpath")
    assert response1.ok
    json_body1 = await response1.json()
    firstCall = json_body1["visitor_count"]

    #second call to the api
    response2 = await context.post("https://l7241ivbyh.execute-api.us-east-1.amazonaws.com/development/subpath")
    assert response2.ok
    json_body2 = await response2.json()
    secondCall = json_body2["visitor_count"]

    #check that the second call is incremented from first call by 1
    assert secondCall == firstCall + 1

    #check that any method aside from post and option returns a 403
    badResponse = await context.get("https://l7241ivbyh.execute-api.us-east-1.amazonaws.com/development/subpath")
    assert badResponse.status == 403


async def main():
    async with async_playwright() as playwright:
        await run(playwright)

asyncio.run(main())


