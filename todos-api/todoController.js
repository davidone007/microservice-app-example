"use strict";
const db = require("./db");
const { v4: uuidv4 } = require("uuid");
const {
  Annotation,
  jsonEncoder: { JSON_V2 },
} = require("zipkin");

const OPERATION_CREATE = "CREATE",
  OPERATION_DELETE = "DELETE";

class TodoController {
  constructor({ tracer, redisClient, logChannel }) {
    this._tracer = tracer;
    this._redisClient = redisClient;
    this._logChannel = logChannel;
  }

  async list(req, res) {
    const query = 'SELECT * FROM todos WHERE "userId" = $1';
    try {
      const { rows } = await db.query(query, [req.user.username]);
      res.json(rows);
    } catch (error) {
      res.status(400).send(error);
    }
  }

  async create(req, res) {
    const query =
      'INSERT INTO todos(id, text, done, "userId") VALUES($1, $2, $3, $4) returning *';
    const values = [uuidv4(), req.body.content, false, req.user.username];

    try {
      const { rows } = await db.query(query, values);
      this._logOperation(OPERATION_CREATE, req.user.username, rows[0].id);
      res.status(201).json(rows[0]);
    } catch (error) {
      res.status(400).send(error);
    }
  }

  async delete(req, res) {
    const query = 'DELETE FROM todos WHERE id=$1 and "userId" = $2';
    try {
      await db.query(query, [req.params.taskId, req.user.username]);
      this._logOperation(
        OPERATION_DELETE,
        req.user.username,
        req.params.taskId
      );
      res.status(204).send();
    } catch (error) {
      res.status(400).send(error);
    }
  }

  _logOperation(opName, username, todoId) {
    this._tracer.scoped(() => {
      const traceId = this._tracer.id;
      this._redisClient.publish(
        this._logChannel,
        JSON.stringify({
          zipkinSpan: traceId,
          opName: opName,
          username: username,
          todoId: todoId,
        })
      );
    });
  }
}

module.exports = TodoController;
