Feature: Validate AWS Instance Configuration

  Scenario Outline: Ensure instance configurations are compliant
    Given I have aws_instance defined
    Then it must contain instance_type
    And its value must be <instance_type>
    And it must contain ebs_optimized
    And its value must be true
    And it must contain monitoring
    And its value must be true
    And it must contain metadata_options
    And it must contain http_tokens
    And its value must be required
    And it must contain root_block_device
    And it must contain encrypted
    And its value must be true
    And it must contain tags
    And its value must be <tag_value>

  Examples:
    | instance_type | tag_value          |
    | t2.micro      | Terraform-Profile  |
    | t2.micro      | terraform-test     |

