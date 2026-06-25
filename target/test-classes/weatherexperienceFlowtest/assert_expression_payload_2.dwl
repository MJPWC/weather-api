%dw 2.0
import * from dw::test::Asserts
fun main(vars: Object) = do {
  var payload = vars.payload
  ---
  payload must equalTo({
  "status": "SUCCESS"
})
}
