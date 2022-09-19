const mysrvdemo = function (srv) {
  srv.on("someFunction", (req, res) => {
    return "hello " + req.data.msg;
  });
};

module.exports = mysrvdemo;



