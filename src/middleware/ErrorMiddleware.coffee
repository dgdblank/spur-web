module.exports = (SpurErrors, Logger, HtmlErrorRender, BaseMiddleware)->

  new class ErrorMiddleware extends BaseMiddleware

    configure:(@app)->
      super
      @app.use @throwNotFoundError
      @app.use @middleware(@)

    throwNotFoundError:(req, res, next)->
      next(SpurErrors.NotFoundError.create("Not Found"))

    middleware:(self)-> (err, req, res, next)=>
      Logger.error(err)
      Logger.error(err.stack)
      Logger.error(err.data) if err.data

      unless err.statusCode
        err = SpurErrors.InternalServerError.create(err.message, err)

      res.status(err.statusCode)

      res.format
        text:()=>
          @sendTextResponse(err, req, res)
        html:()=>
          @sendHtmlResponse(err, req, res)
        json:()=>
          @sendJsonResponse(err, req, res)

    sendTextResponse: (err, req, res)->
      res.send(err.message)

    sendHtmlResponse: (err, req, res)->
      HtmlErrorRender.render(err, req, res)

    sendJsonResponse: (err, req, res)->
      res.json({error: err.message, data: err.data})
