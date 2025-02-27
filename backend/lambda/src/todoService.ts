import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import {
  DynamoDBDocumentClient,
  GetCommand,
  PutCommand,
  DeleteCommand,
  ScanCommand,
} from '@aws-sdk/lib-dynamodb';
import { CreateTodoInput, Todo, UpdateTodoInput } from './types';

const ddbClient = new DynamoDBClient({});
const ddbDocClient = DynamoDBDocumentClient.from(ddbClient);
const TableName = process.env.TODO_TABLE_NAME || 'TodoTable';

export const todoService = {
  async getTodos(): Promise<Todo[]> {
    const result = await ddbDocClient.send(
      new ScanCommand({
        TableName,
      })
    );
    return (result.Items || []) as Todo[];
  },

  async getTodo(id: string): Promise<Todo | null> {
    const result = await ddbDocClient.send(
      new GetCommand({
        TableName,
        Key: { id },
      })
    );
    return (result.Item as Todo) || null;
  },

  async createTodo(input: CreateTodoInput): Promise<Todo> {
    const now = new Date().toISOString();
    const todo: Todo = {
      id: Date.now().toString(),
      title: input.title,
      description: input.description,
      completed: false,
      createdAt: now,
      updatedAt: now,
    };

    await ddbDocClient.send(
      new PutCommand({
        TableName,
        Item: todo,
      })
    );

    return todo;
  },

  async updateTodo(id: string, input: UpdateTodoInput): Promise<Todo | null> {
    const todo = await this.getTodo(id);
    if (!todo) return null;

    const updatedTodo: Todo = {
      ...todo,
      ...input,
      updatedAt: new Date().toISOString(),
    };

    await ddbDocClient.send(
      new PutCommand({
        TableName,
        Item: updatedTodo,
      })
    );

    return updatedTodo;
  },

  async deleteTodo(id: string): Promise<boolean> {
    const todo = await this.getTodo(id);
    if (!todo) return false;

    await ddbDocClient.send(
      new DeleteCommand({
        TableName,
        Key: { id },
      })
    );

    return true;
  },
};
