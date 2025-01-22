import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { todoService } from './todoService';

export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  try {
    const { httpMethod, resource, pathParameters, body } = event;

    // CORS 헤더 설정
    const headers = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,X-Api-Key,X-Amz-Security-Token',
    };

    // OPTIONS 요청 처리 (CORS preflight)
    if (httpMethod === 'OPTIONS') {
      return {
        statusCode: 200,
        headers,
        body: '',
      };
    }

    // API 엔드포인트 처리
    switch (`${httpMethod} ${resource}`) {
      case 'GET /todos':
        const todos = await todoService.getTodos();
        return {
          statusCode: 200,
          headers,
          body: JSON.stringify(todos),
        };

      case 'GET /todos/{id}':
        const todo = await todoService.getTodo(pathParameters?.id!);
        if (!todo) {
          return {
            statusCode: 404,
            headers,
            body: JSON.stringify({ message: 'Todo not found' }),
          };
        }
        return {
          statusCode: 200,
          headers,
          body: JSON.stringify(todo),
        };

      case 'POST /todos':
        const newTodo = await todoService.createTodo(JSON.parse(body!));
        return {
          statusCode: 201,
          headers,
          body: JSON.stringify(newTodo),
        };

      case 'PUT /todos/{id}':
        const updatedTodo = await todoService.updateTodo(
          pathParameters?.id!,
          JSON.parse(body!)
        );
        if (!updatedTodo) {
          return {
            statusCode: 404,
            headers,
            body: JSON.stringify({ message: 'Todo not found' }),
          };
        }
        return {
          statusCode: 200,
          headers,
          body: JSON.stringify(updatedTodo),
        };

      case 'DELETE /todos/{id}':
        const deleted = await todoService.deleteTodo(pathParameters?.id!);
        if (!deleted) {
          return {
            statusCode: 404,
            headers,
            body: JSON.stringify({ message: 'Todo not found' }),
          };
        }
        return {
          statusCode: 204,
          headers,
          body: '',
        };

      default:
        return {
          statusCode: 404,
          headers,
          body: JSON.stringify({ message: 'Not found' }),
        };
    }
  } catch (error) {
    console.error('Error:', error);
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({ message: 'Internal server error' }),
    };
  }
};