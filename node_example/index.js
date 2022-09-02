exports.handler = async (event, context) => {
  console.log(JSON.stringify(event));
  console.log(JSON.stringify(context));

  return {
    statusCode: 200,
    body: "ok",
  };
};
