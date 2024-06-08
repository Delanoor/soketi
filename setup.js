const {
  DynamoDBClient,
  GetItemCommand,
  CreateTableCommand,
  UpdateTableCommand,
  PutItemCommand,
  ImportTableCommand,
} = require("@aws-sdk/client-dynamodb");

const { v4: uuidv4 } = require("uuid");
import { nanoid } from "nanoid";

const client = new DynamoDBClient({
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  },
});

// const apps = [
//   {
//     id: "e1773575-c03a-49bc-9c84-d739089be531",
//     key: "habsida-lms",
//     secret: "BusEcP2/xqkB4tBJgfZaWm6HfczxaRO6S/ne+QUePg4=",
//     enabled: true,
//     enableStats: false,
//     enableClientMessages: true,
//     webhooks: [],
//     maxBackendEventsPerSecond: -1,
//     maxClientEventsPerSecond: -1,
//     maxReadRequestsPerSecond: -1,
//     maxPresenceMembersPerChannel: 100,
//     maxPresenceMemberSizeInKb: 2,
//     maxChannelNameLength: 200,
//     maxEventChannelsAtOnce: 10,
//     maxEventNameLength: 100,
//     maxEventPayloadInKb: 4,
//     maxEventBatchSize: 10,
//   },
//   {
//     id: "5495CC4F-E2ED-41C0-BC0D-1789715AA4D4",
//     key: "crevai-dev",
//     secret: "ZUYS5OMTu4QsxCctad0X0wFYy09b1lVcZ7aom5JZ/9w=",
//     enabled: true,
//     enableStats: false,
//     enableClientMessages: true,
//     webhooks: [],
//     maxBackendEventsPerSecond: -1,
//     maxClientEventsPerSecond: -1,
//     maxReadRequestsPerSecond: -1,
//     maxPresenceMembersPerChannel: 100,
//     maxPresenceMemberSizeInKb: 2,
//     maxChannelNameLength: 200,
//     maxEventChannelsAtOnce: 10,
//     maxEventNameLength: 100,
//     maxEventPayloadInKb: 4,
//     maxEventBatchSize: 10,
//   },
//   {
//     id: "06B19A9C-D165-402A-BB5D-7C981D98FA01",
//     key: "utown-dev",
//     secret: "8GCW6lJZ41pB7uU+4Lrql0n8I5Q0z5Mce6faJlSH0SU=",
//     enabled: true,
//     enableStats: false,
//     enableClientMessages: true,
//     webhooks: [],
//     maxBackendEventsPerSecond: -1,
//     maxClientEventsPerSecond: -1,
//     maxReadRequestsPerSecond: -1,
//     maxPresenceMembersPerChannel: 100,
//     maxPresenceMemberSizeInKb: 2,
//     maxChannelNameLength: 200,
//     maxEventChannelsAtOnce: 10,
//     maxEventNameLength: 100,
//     maxEventPayloadInKb: 4,
//     maxEventBatchSize: 10,
//   },
// ];

// async function putItems() {
//   const command = new PutItemCommand({
//     TableName: "soketi-apps",
//     Item: {
//       AppId: { S: uuidv4() },
//       AppKey: { S: "anychat" },
//       AppSecret: { S: nanoid(32) },
//       EnableClientMessages: { BOOL: true },
//       Enabled: { BOOL: true },
//       MaxBackendEventsPerSecond: { N: String(-1) },
//       MaxClientEventsPerSecond: { N: String(-1) },
//       MaxReadRequestsPerSecond: { N: String(-1) },
//     },
//   });

//   try {
//     const response = await client.send(command);
//     console.log("Success", response);
//   } catch (err) {
//     console.error("Error", err);
//   }
// }

// putItems();

// const tableInput = {
//   AttributeDefinitions: [
//     {
//       AttributeName: "AppId",
//       AttributeType: "S",
//     },
//     {
//       AttributeName: "AppKey",
//       AttributeType: "S",
//     },
//   ],

//   KeySchema: [
//     {
//       AttributeName: "AppId",
//       KeyType: "HASH",
//     },
//   ],

//   GlobalSecondaryIndexes: [
//     {
//       IndexName: "AppKeyIndex",
//       KeySchema: [
//         {
//           AttributeName: "AppKey",
//           KeyType: "HASH",
//         },
//       ],
//       Projection: {
//         ProjectionType: "ALL",
//       },
//       ProvisionedThroughput: {
//         ReadCapacityUnits: 1, // Example value
//         WriteCapacityUnits: 1, // Example value
//       },
//     },
//   ],
//   BillingMode: "PROVISIONED",
//   ProvisionedThroughput: {
//     ReadCapacityUnits: Number(5), // required
//     WriteCapacityUnits: Number(5), // required
//   },

//   TableName: "soketi-apps",
// };

// const command = new CreateTableCommand(tableInput);
// const response = await client.send(command);
// console.log("🚀 ~ file: setup.js:153 ~ response:", response);

const command = new GetItemCommand({
  TableName: "soketi-apps",
  Key: {
    AppId: {
      S: "11452949-6cdf-4059-bf36-b81cec89b85c",
    },
  },
});

const response = await client.send(command);
console.log("🚀 ~ file: setup.js:161 ~ response:", response);
