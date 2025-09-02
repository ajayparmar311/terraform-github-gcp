// udf-transform.js
/**
 * UDF function to transform Pub/Sub messages for BigQuery
 * @param {string} message - Pub/Sub message data
 * @return {Object} - Transformed object for BigQuery
 */
function transformMessage(message) {
  try {
    const data = JSON.parse(message);
    
    return {
      store_id: data.store_id || 'unknown',
      timestamp: data.timestamp || new Date().toISOString(),
      app_info: data.app_info,
      message_id: data.message_id,
      event: data.event,
      event_value: data.event_value,
      insert_id: data.insert_id || generateUUID(),
      processing_time: new Date().toISOString()
    };
  } catch (error) {
    // Return error object for dead letter queue
    return {
      error: error.message,
      original_message: message,
      processing_time: new Date().toISOString()
    };
  } 
}

function generateUUID() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0;
    const v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

// Export for Dataflow UDF
// module.exports = { transformMessage };