def handler_name(event, context):
  print(event)
  print(context)
  return {
    statusCode: 200,
    body: "ok"
  }